variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC."
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "node_group_name" {
  description = "Name of the EKS node group."
  type        = string
}

variable "capacity_type" {
  description = "Capacity type for the node group (e.g., ON_DEMAND, SPOT)."
  type        = string
}

variable "instance_types" {
  description = "List of instance types for the node group."
  type        = list(string)
}

variable "max_size" {
  description = "Maximum number of nodes in the node group."
  type        = number
}

variable "desired_size" {
  description = "Desired number of nodes in the node group."
  type        = number
}

variable "node_name" {
  description = "Base name for the EKS nodes."
  type        = string
}

variable "REGION" {
  description = "AWS region where the resources will be deployed."
  type        = string
}

variable "ACCOUNT" {
  description = "AWS account ID."
  type        = string
}

variable "CredSecret" {
  description = "Name of the AWS credentials secret."
  type        = string
}

variable "EbsCredSecret" {
  description = "Name of the EBS CSI driver secret."
  type        = string
}
