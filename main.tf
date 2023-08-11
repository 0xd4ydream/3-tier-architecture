# Modules

# Presentation tier module
module "presentation" {
  source = "./modules/presentation"

  presentation_alb_sg_id      = aws_security_group.presentation_alb_sg.id
  presentation_instance_sg_id = aws_security_group.presentation_instance_sg.id
  presentation_subnet_id      = aws_subnet.presentation_subnet.id
  vpc_id                      = aws_vpc.vpc.id
  route_table_id              = aws_route_table.rt.id
}

# Application tier module
module "application" {
  source = "./modules/application"

  application_instance_sg_id = aws_security_group.application_instance_sg.id
  application_subnet_id      = aws_subnet.application_subnet.id
}

# Database tier module
module "database" {
  source = "./modules/database"

  database_subnet_id = aws_subnet.database_subnet.id
  database_rds_sg_id = aws_security_group.database_rds_sg.id
}

# Core Infrastructure

# VPC (Virtual Private Cloud)
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "3Tier-VPC"
  }
}

# Internet Gateway (IGW)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "3Tier-IGW"
  }
}

# Subnets

# Presentation tier Subnet
resource "aws_subnet" "presentation_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.presentation_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "3Tier-Presentation-Subnet"
  }
}

# Application Tier Subnet
resource "aws_subnet" "application_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.application_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "3Tier-Application-Subnet"
  }
}

# Database Tier Subnet
resource "aws_subnet" "database_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.database_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "3Tier-Database-Subnet"
  }
}

# Route Table (RT)
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "3Tier-RT"
  }
}

# Security Group for Presentation Tier Instances to allow HTTP and HTTPS traffic from ALB and SSH from a specified IP.
resource "aws_security_group" "presentation_instance_sg" {
  name_prefix = "presentation-instance-"
  description = "Security group for presentation tier instances"

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.presentation_alb_sg.id]
  }

  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.presentation_alb_sg.id]
  }

  ingress {
    description = "SSH from a specified IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_access_ip}/32"]
  }

  tags = {
    Name = "3Tier-Presentation-Instance-SG"
  }
}

# Security Group for Presentation Tier Load Balancer to allow HTTP and HTTPS inbound traffic from the Internet.
resource "aws_security_group" "presentation_alb_sg" {
  name_prefix = "presentation-ALB-"
  description = "Security group for presentation tier load balancer"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "3Tier-Presentation-ALB-SG"
  }
}

# Security Group for Application Tier Instances to allow traffic from the Presentation Tier and within the Application Tier.
resource "aws_security_group" "application_instance_sg" {
  name_prefix = "application-instance-"
  description = "Security group for application tier instances"

  # Allow incoming traffic from the presentation tier ALB.
  ingress {
    description     = "HTTP from Presentation Tier ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.presentation_alb_sg.id]
  }

  # Allow incoming traffic from the presentation tier ALB on HTTPS.
  ingress {
    description     = "HTTPS from Presentation Tier ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.presentation_alb_sg.id]
  }

  # Allow incoming traffic from the database tier on the ephemeral port range.
  ingress {
    description     = "Database Access"
    from_port       = 1024
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.database_rds_sg.id]
  }

  tags = {
    Name = "3Tier-Application-Instance-SG"
  }
}

# Security Group for Database Tier Instances to allow traffic from the Application Tier.
resource "aws_security_group" "database_rds_sg" {
  name_prefix = "database-RDS-"
  description = "Security group for database tier RDS"

  tags = {
    Name = "3Tier-Database-RDS-SG"
  }
}

# Note: `aws_security_group_rule` is used here to prevent a cyclic dependency
# Allow incoming traffic from the application tier.
resource "aws_security_group_rule" "app_to_db" {
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.database_rds_sg.id
  source_security_group_id = aws_security_group.application_instance_sg.id
}

# Create Presentation Tier Subnet NACL
resource "aws_network_acl" "presentation_nacl" {
  vpc_id = aws_vpc.vpc.id

  # Inbound Rules to allow HTTP from the internet.
  ingress {
    rule_no    = 100
    action     = "allow"
    from_port  = 80
    to_port    = 80
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  # Inbound Rules to allow HTTPS from the internet.
  ingress {
    rule_no    = 200
    action     = "allow"
    from_port  = 443
    to_port    = 443
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  # Note: Includes traffic to Presentation Tier
  # Outbound Rules to allow all traffic to the internet.
  egress {
    rule_no    = 100
    action     = "allow"
    from_port  = 1024
    to_port    = 65535
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "3Tier-Presentation-ACL"
  }
}

# Associate Presentation NACL with Presentation Subnet
resource "aws_network_acl_association" "presentation_subnet_associations" {
  subnet_id      = aws_subnet.presentation_subnet.id
  network_acl_id = aws_network_acl.presentation_nacl.id
}

# Create Application Tier Subnet NACL
resource "aws_network_acl" "application_nacl" {
  vpc_id = aws_vpc.vpc.id

  # Inbound Rule to allow SSH traffic from a specified IP address
  ingress {
    rule_no    = 100
    action     = "allow"
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"
    cidr_block = "${var.ssh_access_ip}/32"
  }

  # Inbound Rule to allow traffic from the Presentation Tier.
  ingress {
    rule_no    = 200
    action     = "allow"
    from_port  = 1024
    to_port    = 65535
    protocol   = "tcp"
    cidr_block = var.presentation_cidr
  }

  # Inbound Rule to allow traffic from the Database Tier.
  ingress {
    rule_no    = 300
    action     = "allow"
    from_port  = 1024
    to_port    = 65535
    protocol   = "tcp"
    cidr_block = var.database_cidr
  }

  # Outbound Rule to allow HTTP traffic to the Presentation Tier.
  egress {
    rule_no    = 100
    action     = "allow"
    from_port  = 80
    to_port    = 80
    protocol   = "tcp"
    cidr_block = var.presentation_cidr
  }

  # Outbound Rule to allow HTTPS traffic to the Presentation Tier.
  egress {
    rule_no    = 100
    action     = "allow"
    from_port  = 443
    to_port    = 443
    protocol   = "tcp"
    cidr_block = var.presentation_cidr
  }

  # Outbound Rule to allow traffic to the Database Tier.
  egress {
    rule_no    = 200
    action     = "allow"
    from_port  = var.db_port
    to_port    = var.db_port
    protocol   = "tcp"
    cidr_block = var.database_cidr
  }

  tags = {
    Name = "3Tier-Application-ACL"
  }
}

# Associate Application NACL with Application Subnet
resource "aws_network_acl_association" "application_subnet_associations" {
  subnet_id      = aws_subnet.application_subnet.id
  network_acl_id = aws_network_acl.application_nacl.id
}

# Create Database Tier Subnet NACL
resource "aws_network_acl" "database_nacl" {
  vpc_id = aws_vpc.vpc.id

  # Inbound Rule to allow traffic from the Application Tier.
  ingress {
    rule_no    = 100
    action     = "allow"
    from_port  = var.db_port
    to_port    = var.db_port
    protocol   = "tcp"
    cidr_block = var.application_cidr
  }

  # Outbound Rule to allow traffic to the Application Tier.
  egress {
    rule_no    = 100
    action     = "allow"
    from_port  = 1024
    to_port    = 65535
    protocol   = "tcp"
    cidr_block = var.application_cidr
  }

  tags = {
    Name = "3Tier-Database-ACL"
  }
}

# Associate Database NACL with Database Subnet
resource "aws_network_acl_association" "database_subnet_associations" {
  subnet_id      = aws_subnet.database_subnet.id
  network_acl_id = aws_network_acl.database_nacl.id
}
