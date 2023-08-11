output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "presentation_subnet_ids" {
  description = "Presentation Tier Subnet ID"
  value       = aws_subnet.presentation_subnet.id
}

output "application_subnet_ids" {
  description = "Application Tier Subnet ID"
  value       = aws_subnet.application_subnet.id
}

output "database_subnet_id" {
  description = "Database Tier Subnet ID"
  value       = aws_subnet.database_subnet.id
}

output "presentation_instance_sg_id" {
  description = "ID of the Presentation Tier Instances Security Group"
  value       = aws_security_group.presentation_instance_sg.id
}

output "presentation_alb_sg_id" {
  description = "ID of the Presentation Tier ALB Security Group"
  value       = aws_security_group.presentation_alb_sg.id
}

output "application_sg_id" {
  description = "ID of the Application Tier Instances Security Group"
  value       = aws_security_group.application_instance_sg.id
}

output "database_sg_id" {
  description = "ID of the Database Tier RDS Security Group"
  value       = aws_security_group.database_rds_sg.id
}

output "presentation_nacl_id" {
  description = "ID of the Presentation Tier Network ACL"
  value       = aws_network_acl.presentation_nacl.id
}

output "application_nacl_id" {
  description = "ID of the Application Tier Network ACL"
  value       = aws_network_acl.application_nacl.id
}

output "database_nacl_id" {
  description = "ID of the Database Tier Network ACL"
  value       = aws_network_acl.database_nacl.id
}
