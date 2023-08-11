variable "application_instance_sg_id" {
  type        = string
  description = "Application EC2 Security Group"
}

variable "application_subnet_id" {
  type        = string
  description = "Application tier Subnet"
}

variable "application_ami" {
  description = "AMI for EC2 instances running in the Application Tier"
  type        = string
  default     = "ami-040d60c831d02d41c" # Amazon Linux 2023 AMI
}

variable "application_ec2_type" {
  description = "Instance type for EC2 instances running in the Application Tier"
  type        = string
  default     = "t3.micro"
}

variable "application_vol_size" {
  description = "EBS size for EC2 instances running in the Application Tier"
  type        = number
  default     = 30
}

variable "application_vol_type" {
  description = "EBS type for EC2 instances running in the Application Tier"
  type        = string
  default     = "gp2"
}

variable "application_key" {
  description = "Key pair name for SSH access"
  type        = string
  default     = "application-key" # Replace with your key pair name for SSH access
}

variable "application_dev_name" {
  description = "Device name for the volume of EC2 instances running in the Application Tier"
  type        = string
  default     = "/dev/xvda"
}

variable "application_asg_min" {
  description = "Minimum number of instances in the ASG in the Application Tier"
  type        = number
  default     = 1
}

variable "application_asg_max" {
  description = "Maximum number of instances in the ASG in the Application Tier"
  type        = number
  default     = 3
}

variable "application_max_threshold" {
  type        = number
  description = "Defines the upper limit of CPU usage below which the Auto Scaling system will take action to scale out"
  default     = 70
}

variable "application_min_threshold" {
  type        = number
  description = "Defines the lower limit of CPU usage below which the Auto Scaling system will take action to scale in"
  default     = 20
}
