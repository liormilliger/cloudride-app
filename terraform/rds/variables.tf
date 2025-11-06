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

variable "db_subnet_group_name" {
  description = "The DB Subnet Group name for the new RDS instance."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "A list of VPC Security Group IDs to associate with the new RDS instance."
  type        = list(string)
}

variable "new_master_password" {
  description = "The new master password for the cloned database."
  type        = string
  sensitive   = true
}