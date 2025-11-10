# resource "aws_db_subnet_group" "rds_subnet_group" {
#   name        = "liorm-cloudride-rds-sng"
#   subnet_ids  = var.db_subnet_ids
#   tags = {
#     Name = "liorm-cloudride-rds-sng"
#   }
# }

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
    vpc_id = var.vpc_id
    public_subnet_ids = var.public_subnet_ids
    private_subnet_ids = var.private_subnet_ids
    RDS_SECRET_NAME = var.RDS_SECRET_NAME

}

# module "rds" {
#   source = "./rds"

#   source_db_identifier       = var.source_db_identifier
#   source_snapshot_identifier = var.source_snapshot_identifier
#   new_db_identifier          = var.new_db_identifier
#   new_master_password        = var.new_master_password
#   db_subnet_group_name       = aws_db_subnet_group.rds_subnet_group.name 
#   vpc_security_group_ids     = [var.db_security_group_id] 

#   depends_on = [
#     aws_db_subnet_group.rds_subnet_group
#   ]
# }

# output "new_rds_endpoint" {
#   value       = module.rds.db_endpoint
#   description = "The endpoint of the newly created, managed RDS instance."
# }

# resource "local_file" "rds_helm_values" {
#   filename = "argocd/mywebsite-helm-values.yaml" 
  
#   content = templatefile("${path.module}/helm-values-template.yaml", {
#     rds_endpoint  = "cloudride-legacy-db.c0kc8dxradrc.us-west-2.rds.amazonaws.com"
#     db_name       = "restaurants"
#     db_username   = module.eks.db_username
#     db_password   = module.eks.db_password 
#   })
# }

module "argocd" {
  source                 = "./argocd"
  config_repo_url         = var.config_repo_url
  argocd-private-key = var.argocd-private-key
  # RDS_SECRET_NAME = var.RDS_SECRET_NAME
  eso_irsa_role_arn = module.eks.eso_irsa_role_arn 
  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }

  depends_on = [
    module.eks
  ]
}



