terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}

# provider "kubernetes" {
#   config_path = "~/.kube/config" 
#   host = data.aws_eks_cluster.example.endpoint 
#   token = data.aws_eks_cluster_auth.example.token 
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.example.certificate_authority[0].data)
# }

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

data "aws_secretsmanager_secret_version" "argocd-private-key" {
  secret_id = var.argocd-private-key
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "5.51.2"

  values = [
    yamlencode({
      configs = {
        repositories = {
          my-config-repo = {
            name           = "my-config-repo"
            type           = "git"
            url            = var.config_repo_url
            sshPrivateKey = replace(jsondecode(data.aws_secretsmanager_secret_version.argocd-private-key.secret_string)["argocd-private-key"], "\\n", "\n")
          }
        }
      }
    })
  ]
}

# -----------------------------------------------------------------------------
# RDS Secrets Manager Data Sources (New Blocks)
# -----------------------------------------------------------------------------

# 1. Get the secret metadata using the variable (which you must define in the module)
data "aws_secretsmanager_secret" "rds_credentials_meta" {
  # The secret name is passed in via a variable from the root module
  name = var.RDS_SECRET_NAME 
}

# 2. Get the actual secret string
data "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = data.aws_secretsmanager_secret.rds_credentials_meta.id
}

# Inside ./eks/node-group.tf (or a dedicated locals.tf in the EKS module)
locals {
  # Parse the JSON string retrieved from Secrets Manager
  rds_secret_json = jsondecode(data.aws_secretsmanager_secret_version.rds_credentials.secret_string)
}

resource "time_sleep" "wait_for_crd_registration" {
  create_duration = "30s"
  depends_on      = [ helm_release.argocd ]
}

resource "kubernetes_manifest" "app_of_apps" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "app-of-apps"
      namespace = "argocd"
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.config_repo_url
        path           = "argocd-apps"
        targetRevision = "main"
        helm = {
          parameters = [
            {
              name  = "rds.username"
              value = local.rds_secret_json.username
            },
            {
              name  = "rds.password"
              value = local.rds_secret_json.password
            },
          ]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }

  depends_on = [
    time_sleep.wait_for_crd_registration
  ]
}
