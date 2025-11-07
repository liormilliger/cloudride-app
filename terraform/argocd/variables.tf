variable "config_repo_url" {
  description = "URL to mywebsite-k8s github repo"
  type = string
}

variable argocd-private-key {
  description = "Secret name from aws secret manager"
  type = string
}
