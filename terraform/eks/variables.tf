### GENERAL VARS ###

variable "REGION" {
  description = "AWS region where the resources will be deployed."
  type        = string
}

variable "ACCOUNT" {
  description = "AWS account ID."
  type        = string
}

### NETWORK VARS ###

variable "vpc_id" {
  description = "ID of the existing VPC."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of existing private subnet IDs for the EKS module."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of existing public subnet IDs for the EKS module."
  type        = list(string)
}

### CLUSTER VARS ###

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}

### NODE VARS ###

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

### SECRETS VARS ###

variable "CredSecret" {
  description = "Name of the AWS credentials secret."
  type        = string
}

variable "EbsCredSecret" {
  description = "Name of the EBS CSI driver secret."
  type        = string
}