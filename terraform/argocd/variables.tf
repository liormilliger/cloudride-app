variable "config_repo_url" {
  description = "URL to mywebsite-k8s github repo"
  type = string
}

variable argocd-private-key {
  description = "Secret name from aws secret manager"
  type = string
}

variable "eso_irsa_role_arn" {
  description = "The ARN of the IAM role for the External Secrets Operator service account."
  type        = string
}