output "application_asg_name" {
  description = "Name of the Application Tier ASG"
  value       = aws_autoscaling_group.application_asg.name
}
