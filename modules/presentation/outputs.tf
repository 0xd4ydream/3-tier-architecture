output "presentation_alb_dns_name" {
  description = "The DNS name of the Application Load Balancer in the Presentation Tier"
  value       = aws_lb.alb.dns_name
}

output "presentation_asg_name" {
  description = "Name of the Presentation Tier ASG"
  value       = aws_autoscaling_group.presentation_asg.name
}
