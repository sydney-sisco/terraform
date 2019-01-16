variable "admin_username" {}
variable "admin_password" {}
variable "database_name" {}

resource "aws_rds_cluster" "default" {
  availability_zones      = ["us-west-2a", "us-west-2b", "us-west-2c"]
  cluster_identifier_prefix = "${var.database_name}-"
  engine_mode = "serverless"
  master_username         = "${var.admin_username}" # Alphanumeric string that must be 1 to 16 characters long
  master_password         = "${var.admin_password}" # Can be any printable ASCII character except "/", """, or "@", must be at most 41 characters
  backup_retention_period = 1
  preferred_backup_window = "09:00-11:00" # Time in UTC
  preferred_maintenance_window = "sun:11:00-sun:11:30" # UTC

  scaling_configuration {
    auto_pause               = true
    max_capacity             = 2
    min_capacity             = 2
    seconds_until_auto_pause = 300
  }

  skip_final_snapshot = true
}