output "db_instance_endpoint" {
  description = "Endpoint address of the RDS database instance"
  value       = aws_db_instance.RDS.endpoint
}
