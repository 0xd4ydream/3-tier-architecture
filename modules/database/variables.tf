variable "database_subnet_id" {
  type        = string
  description = "Database Subnet"
}

variable "database_rds_sg_id" {
  type        = string
  description = "Database Security Group"
}

variable "db_storage" {
  type        = number
  description = "The allocated storage in gibibytes"
  default     = 10
}

variable "db_name" {
  type        = string
  description = "The database name"
  default     = "mydb"
}

variable "db_engine" {
  type        = string
  description = "The database engine"
  default     = "postgresql"
}

variable "db_engine_version" {
  type        = string
  description = "The database engine version"
  default     = 10
}

variable "db_class" {
  type        = string
  description = "The instance type of the RDS instance"
  default     = "db.t3.micro"
}

variable "db_username" {
  type        = string
  description = "Username for the master DB user"
  default     = "foo"
}

variable "db_password" {
  type        = string
  description = "Password for the master DB user"
  default     = "foobarbaz"
}

variable "db_multi_az" {
  type        = bool
  description = "If the RDS instance is multi AZ enabled"
  default     = true
}

variable "db_encryption" {
  type        = bool
  description = "Whether the DB instance is encrypted"
  default     = true
}

variable "db_retention_period" {
  type        = number
  description = "The backup retention period"
  default     = 7
}

variable "db_backup_window" {
  type        = string
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled"
  default     = "07:00-09:00"
}
