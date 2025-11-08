### GENERAL ###

variable "REGION" {
  description = "AWS region where the resources will be deployed."
  type        = string
}

variable "ACCOUNT" {
  description = "AWS account ID."
  type        = string
}

### VPC ###

variable "vpc_name" {
  description = "Name of the VPC."
  type        = string
}

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

### CLUSTER ###

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}

### NODE GROUP ###
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

### RDS CLONE ###

variable "source_db_identifier" {
  description = "The DB identifier of the existing, unmanaged RDS instance."
  type        = string
}

variable "source_snapshot_identifier" {
  description = "The identifier of the manual snapshot to restore from."
  type        = string
}

variable "new_db_identifier" {
  description = "The desired identifier for the new, managed RDS instance."
  type        = string
}

variable "new_master_password" {
  description = "The new master password for the cloned database."
  type        = string
  sensitive   = true
}

variable "db_security_group_id" {
  description = "The ID of the Security Group to attach to the new RDS instance."
  type        = string
}

variable "db_subnet_ids" {
  description = "List of existing DB subnet IDs for the RDS instance."
  type        = list(string)
}

### SECRETS ###

variable "CredSecret" {
  description = "Name of the AWS credentials secret."
  type        = string
}

variable "EbsCredSecret" {
  description = "Name of the EBS CSI driver secret."
  type        = string
}

variable "argocd-private-key" {
  description = "Key for argocd to communicate with K8S repo"
  type = string
}

variable "config_repo_url" {
  description = "git ssh k8s-repo url"
  type = string
}