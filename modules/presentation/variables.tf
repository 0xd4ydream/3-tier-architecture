variable "route_table_id" {
  type        = string
  description = "Route Table"
}

variable "presentation_alb_sg_id" {
  type        = string
  description = "ALB Security Group"
}

variable "presentation_subnet_id" {
  type        = string
  description = "Presentation tier Subnet"
}

variable "vpc_id" {
  type        = string
  description = "VPC"
}

variable "presentation_instance_sg_id" {
  type        = string
  description = "Presentation EC2 Security Group"
}

variable "enable_stickiness" {
  type        = bool
  description = "If set to true, the balancer will attempt to route clients to a consistent back end"
  default     = true
}

variable "health_check_interval" {
  type        = number
  description = "The approximate amount of time, in seconds, between health checks of an individual target"
  default     = 30
}

variable "health_check_path" {
  type        = string
  description = "The destination for the health check request"
  default     = "/"
}

variable "health_check_protocol" {
  type        = string
  description = "The protocol to use to connect with the target"
  default     = "HTTP"
}

variable "health_check_timeout" {
  type        = number
  description = "The amount of time, in seconds, during which no response means a failed health check"
  default     = 6
}

variable "health_check_healthy_threshold" {
  type        = number
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy"
  default     = 3
}

variable "unhealthy_threshold" {
  type        = number
  description = "The number of consecutive health check failures required before considering the target unhealthy"
  default     = 3
}

variable "matcher" {
  type        = string
  description = "Response codes to use when checking for a healthy responses from a target"
  default     = "200"
}

variable "presentation_ami" {
  description = "AMI for EC2 instances running in the Presentation Tier"
  type        = string
  default     = "ami-040d60c831d02d41c" # Amazon Linux 2023 AMI
}

variable "presentation_ec2_type" {
  description = "Instance type for EC2 instances running in the Presentation Tier"
  type        = string
  default     = "t3.micro"
}

variable "presentation_vol_size" {
  description = "EBS size for EC2 instances running in the Presentation Tier"
  type        = number
  default     = 30
}

variable "presentation_vol_type" {
  description = "EBS type for EC2 instances running in the Presentation Tier"
  type        = string
  default     = "gp2"
}

variable "presentation_key" {
  description = "Key pair name for SSH access"
  type        = string
  default     = "presentation-key" # Replace with your key pair name for SSH access
}

variable "presentation_dev_name" {
  description = "Device name for the volume of EC2 instances running in the Presentation Tier"
  type        = string
  default     = "/dev/xvda"
}

variable "presentation_asg_min" {
  description = "Minimum number of instances in the ASG in the Presentation Tier"
  type        = number
  default     = 1
}

variable "presentation_asg_max" {
  description = "Maximum number of instances in the ASG in the Presentation Tier"
  type        = number
  default     = 3
}

variable "presentation_max_threshold" {
  type        = number
  description = "Defines the upper limit of CPU usage below which the Auto Scaling system will take action to scale out"
  default     = 70
}

variable "presentation_min_threshold" {
  type        = number
  description = "Defines the lower limit of CPU usage below which the Auto Scaling system will take action to scale in"
  default     = 20
}
