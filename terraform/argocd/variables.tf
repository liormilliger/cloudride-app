variable "config_repo_url" {
  description = "URL to mywebsite-k8s github repo"
  type = string
}

variable argocd-private-key {
  description = "Secret name from aws secret manager"
  type = string
}

variable "RDS_SECRET_NAME" {
  description = "credentials for RDS"
  type = string
}

