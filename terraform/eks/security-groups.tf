data "aws_vpc" "cluster_vpc" {
  id = aws_eks_cluster.eks-cluster.vpc_config[0].vpc_id
}

resource "aws_security_group" "eks_node_sg" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for EKS cluster worker nodes"
  vpc_id      = aws_eks_cluster.eks-cluster.vpc_config[0].vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_eks_cluster.eks-cluster.vpc_config[0].cluster_security_group_id]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.cluster_vpc.cidr_block]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.cluster_vpc.cidr_block]
  }

  tags = {
    Name = "${var.cluster_name}-node-sg"
    # "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}