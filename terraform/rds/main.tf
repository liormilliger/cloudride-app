# --- 1. Data Source: Get Source DB Configuration (Read-Only) ---
# Fetches instance_class, engine, storage settings, etc., from the existing DB
data "aws_db_instance" "source_db" {
  db_instance_identifier = var.source_db_identifier
}

# --- 2. Data Source: Get Snapshot Details ---
# Fetches the ARN or ID of the specific snapshot provided
data "aws_db_snapshot" "source_snapshot" {
  db_snapshot_identifier = var.source_snapshot_identifier
}

# --- 3. Resource: Create New Managed DB Instance from Snapshot ---
resource "aws_db_instance" "new_managed_db" {
  identifier          = var.new_db_identifier
  
  # CRITICAL: This restores the DB from the snapshot, cloning data and schema.
  snapshot_identifier = data.aws_db_snapshot.source_snapshot.db_snapshot_identifier

  # --- Copying Configuration Attributes from the Data Source ---
  instance_class      = data.aws_db_instance.source_db.instance_class
  engine              = data.aws_db_instance.source_db.engine
  allocated_storage   = data.aws_db_instance.source_db.allocated_storage
  storage_type        = data.aws_db_instance.source_db.storage_type
  
  # Master user/password are copied from the snapshot, but we reset the password for security/control.
  username            = data.aws_db_instance.source_db.username
  password            = var.new_master_password
  
  # --- New Networking and Security ---
  db_subnet_group_name  = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids

  # --- Encryption (if applicable, must match source for restoration) ---
  storage_encrypted   = data.aws_db_instance.source_db.storage_encrypted
  kms_key_id          = data.aws_db_instance.source_db.kms_key_id
  
  # Management settings
  skip_final_snapshot = true 
}