################################################################################
# IAM Role for EBS CSI Driver Service Account
################################################################################

resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "${aws_eks_cluster.eks-cluster.name}-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_oidc_provider.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${aws_eks_cluster.eks-cluster.name}-ebs-csi-driver-role"
  }
}

################################################################################
# IAM Policy Attachment for EBS CSI Driver
################################################################################

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attachment" {
  role       = aws_iam_role.ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

################################################################################
# EKS Add-on for AWS EBS CSI Driver
################################################################################

resource "aws_eks_addon" "ebs_csi_driver" {
  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_driver_policy_attachment,
    aws_eks_node_group.node-group
  ]
  
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn

  tags = {
    "eks_addon" = "ebs-csi-driver"
  }
}

################################################################################
# Installing Kubernetes Networking Components
################################################################################

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "kube-proxy"

  depends_on = [aws_eks_node_group.node-group]
}
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "coredns"

  depends_on = [aws_eks_node_group.node-group]
}
resource "aws_eks_addon" "vpc-cni" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "vpc-cni"

  depends_on = [aws_eks_node_group.node-group]
}
