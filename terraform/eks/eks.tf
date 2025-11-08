# -----------------------------------------------------------------------------
# EKS Cluster IAM Role (For EKS Control Plane Only)
# -----------------------------------------------------------------------------
resource "aws_iam_role" "eks-cluster-iam-role" {
  name = "${var.cluster_name}-iam-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = {
    provisioned_by = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-iam-role.name
}

# -----------------------------------------------------------------------------
# EKS Cluster Definition
# -----------------------------------------------------------------------------
resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks-cluster-iam-role.arn

  tags = {
    provisioned_by = "Terraform"
  }

  lifecycle {
    ignore_changes = [tags]
  }

  vpc_config {
    subnet_ids = concat(var.private_subnet_ids, var.public_subnet_ids)
  }

  depends_on = [aws_iam_role_policy_attachment.eks-cluster-policy]
}

# -----------------------------------------------------------------------------
# OIDC Provider for IAM Roles for Service Accounts (IRSA)
# -----------------------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster_cert.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer

  tags = {
    Name = "oidc-provider-${replace(aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer, "https://", "")}"
  }
}

data "tls_certificate" "eks_cluster_cert" {
  url = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_policy" "alb_controller_policy" {
  name        = "${var.cluster_name}-alb-controller-policy"
  description = "Permissions for AWS Load Balancer Controller"
  policy      = file("${path.module}/policies/iam-policy.json")
}

resource "aws_iam_role_policy_attachment" "alb_controller_policy_attach" {
  role       = aws_iam_role.alb_controller_iam_role.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}

# -----------------------------------------------------------------------------
# ALB Controller IAM Role (For IRSA)
# -----------------------------------------------------------------------------
resource "aws_iam_role" "alb_controller_iam_role" {
  # Naming convention matches the cluster name for easy identification
  name = "${var.cluster_name}-alb-controller-role" 

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.eks_oidc_provider.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${aws_iam_openid_connect_provider.eks_oidc_provider.url}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }
  ]
}
POLICY

  tags = {
    provisioned_by = "Terraform"
  }
}