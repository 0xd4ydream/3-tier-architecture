resource "aws_db_subnet_group" "db_group" {
  name       = "db-subnet-group"
  subnet_ids = [var.database_subnet_id]

  tags = {
    Name = "3Tier-Database-subnet-group"
  }
}

resource "aws_db_instance" "RDS" {
  allocated_storage       = var.db_storage
  db_name                 = var.db_name
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_class
  username                = var.db_username
  password                = var.db_password
  multi_az                = var.db_multi_az
  backup_retention_period = var.db_retention_period
  backup_window           = var.db_backup_window
  storage_encrypted       = var.db_encryption
  vpc_security_group_ids  = [var.database_rds_sg_id]
  db_subnet_group_name    = aws_db_subnet_group.db_group.name

  tags = {
    Name = "3Tier-RDS"
  }
}
