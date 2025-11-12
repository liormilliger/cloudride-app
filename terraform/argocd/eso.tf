resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
  }
}

resource "kubernetes_manifest" "external_secrets_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "external-secrets"
      namespace = "argocd"
      labels = {
        "argocd.argoproj.io/managed-by" = "argocd" 
      }
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://charts.external-secrets.io"
        chart          = "external-secrets"
        targetRevision = "0.9.13"
        helm = {
          parameters = [
            {
              name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
              value = var.eso_irsa_role_arn 
            },
            {
              name = "installCRDs"
              value = "true"
            }
          ]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "external-secrets"
      }
      syncPolicy = {
        automated = {
          prune     = true
          selfHeal  = true
        }
      }
    }
  }
}