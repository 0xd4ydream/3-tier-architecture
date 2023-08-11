variable "aws_region" {
  description = "The AWS region where the infrastructure will be deployed"
  type        = string
  default     = "eu-north-1"
}

variable "availability_zone" {
  description = "The Availability Zone for the subnets"
  type        = string
  default     = "eu-north-1a"
}

variable "db_port" {
  description = "Port number for database connection"
  type        = number
  default     = 5432 # PostgreSQL
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "presentation_cidr" {
  description = "CIDR block for presentation subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "application_cidr" {
  description = "CIDR block for application subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "database_cidr" {
  description = "CIDR block for database subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "ssh_access_ip" {
  description = "SSH access IP address"
  type        = string
  default     = "10.0.0.1" # Placeholder IP address for SSH access
}
