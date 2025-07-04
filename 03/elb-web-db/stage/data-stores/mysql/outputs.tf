output "address" {
  description = "MySQL DB Address"
  value       = aws_db_instance.myDBInstance.address
}

output "port" {
  description = "MySQL DB port"
  value       = aws_db_instance.myDBInstance.port
}