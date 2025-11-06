output "db_endpoint" {
  description = "The DNS endpoint address for the newly created RDS instance."
  value       = aws_db_instance.new_managed_db.address
}

output "db_username" {
  description = "The master username for the new RDS instance."
  value       = aws_db_instance.new_managed_db.username
}