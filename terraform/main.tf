module "eks" {
    source = "./eks"
    cluster_name = var.cluster_name
    max_size = var.max_size
    node_name = var.node_name    
    capacity_type = var.capacity_type
    EbsCredSecret = var.EbsCredSecret
    REGION = var.REGION
    ACCOUNT = var.ACCOUNT
    instance_types = var.instance_types
    node_group_name = var.node_group_name
    cluster_version = var.cluster_version
    CredSecret = var.CredSecret
    desired_size = var.desired_size
    private_subnet_ids = module.vpc.private_subnet_ids
    public_subnet_ids = module.vpc.public_subnet_ids

}

module "argocd" {
  source                 = "./argocd"
  config_repo_url         = "git@github.com:<REPO>"
  config-repo-secret-name = "config-repo-private-sshkey"

  
  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }
  
  depends_on = [module.eks]
}



