output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.eks-cluster.name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster's Kubernetes API server."
  value       = aws_eks_cluster.eks-cluster.endpoint
}

output "cluster_ca_certificate" {
  description = "The base64 encoded certificate data required to communicate with the cluster."
  value       = aws_eks_cluster.eks-cluster.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster."
  value       = aws_iam_openid_connect_provider.eks_oidc_provider.arn
}

output "oidc_provider_url" {
  description = "The URL of the OIDC provider"
  value       = aws_iam_openid_connect_provider.eks_oidc_provider.url
}

# --- RDS Credentials Outputs ---
output "db_host" {
  description = "The database endpoint hostname."
  value = local.rds_secret_json.host
}

output "db_username" {
  description = "The database master username."
  value = local.rds_secret_json.username
}

output "db_password" {
  description = "The database master password."
  value = local.rds_secret_json.password
  sensitive = true
}

output "db_name" {
  description = "The default database name."
  value = local.rds_secret_json.dbname
}
