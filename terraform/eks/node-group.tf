resource "aws_iam_role" "liorm-node-group-role" {
  name = "liorm_node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "liorm-eks-csi-ebs-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.liorm-node-group-role.name
}

resource "aws_iam_role_policy_attachment" "liorm-eks-worker-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.liorm-node-group-role.name
}

resource "aws_iam_role_policy_attachment" "liorm-eks-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.liorm-node-group-role.name
}

resource "aws_iam_role_policy_attachment" "liorm-ec2-container-registry-read-only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.liorm-node-group-role.name
}

resource "aws_eks_node_group" "node-group" {
  cluster_name    = var.cluster_name
  version         = var.cluster_version
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.liorm-node-group-role.arn

  subnet_ids = var.private_subnet_ids

  capacity_type  = var.capacity_type
  instance_types = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
    nodeName = var.node_name
  }
  
  launch_template {
    name    = aws_launch_template.naming-nodes.name
    version = aws_launch_template.naming-nodes.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.liorm-eks-worker-node-policy,
    aws_iam_role_policy_attachment.liorm-eks-cni-policy,
    aws_iam_role_policy_attachment.liorm-ec2-container-registry-read-only,
    aws_eks_cluster.eks-cluster,
  ]

  tags = {
    provisioned_by = "Terraform"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [scaling_config[0].desired_size]
  }
}

resource "aws_launch_template" "naming-nodes" {
  name = "liorm-webapp"
  
  vpc_security_group_ids = [
    aws_security_group.eks_node_sg.id,
    aws_eks_cluster.eks-cluster.vpc_config[0].cluster_security_group_id
  ]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"
    
    tags = {
      Name = var.node_name
    }
  }
}

data "aws_secretsmanager_secret" "aws-credentials" {
  arn = "arn:aws:secretsmanager:${var.REGION}:${var.ACCOUNT}:secret:${var.CredSecret}"
}

data "aws_secretsmanager_secret" "ebs-credentials" {
  arn = "arn:aws:secretsmanager:${var.REGION}:${var.ACCOUNT}:secret:${var.EbsCredSecret}"
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
