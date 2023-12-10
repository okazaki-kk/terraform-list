resource "aws_db_subnet_group" "main" {
  name        = local.name
  subnet_ids  = module.vpc.private_subnets
  description = "DB subnet group for ${local.name}"
}

resource "aws_db_instance" "main" {
  db_name                 = local.name
  identifier              = local.name
  storage_type            = "gp2"
  allocated_storage       = 30
  engine                  = "mysql"
  engine_version          = "5.7.42"
  instance_class          = "db.t3.small"
  vpc_security_group_ids  = [aws_security_group.db.id]
  username                = "admin"
  password                = data.aws_ssm_parameter.admin_db_password.value
  multi_az                = false
  db_subnet_group_name    = aws_db_subnet_group.main.name
  backup_retention_period = 7
  availability_zone       = "ap-northeast-1a"
  network_type            = "IPV4"
  port                    = 3306
  skip_final_snapshot     = true
  parameter_group_name    = aws_db_parameter_group.main.name
}


resource "aws_db_parameter_group" "main" {
  name        = local.name
  family      = "mysql5.7"
  description = "db parameter group for ${local.name} application"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    apply_method = "immediate"
    name         = "character_set_client"
    value        = "utf8mb4"
  }
  parameter {
    apply_method = "immediate"
    name         = "character_set_connection"
    value        = "utf8mb4"
  }
  parameter {
    apply_method = "immediate"
    name         = "character_set_database"
    value        = "utf8mb4"
  }
  parameter {
    apply_method = "immediate"
    name         = "character_set_results"
    value        = "utf8mb4"
  }
  parameter {
    apply_method = "immediate"
    name         = "collation_connection"
    value        = "utf8mb4_unicode_ci"
  }
  parameter {
    apply_method = "immediate"
    name         = "init_connect"
    value        = "SET NAMES utf8mb4"
  }
  parameter {
    apply_method = "immediate"
    name         = "log_bin_trust_function_creators"
    value        = "1"
  }
  parameter {
    apply_method = "immediate"
    name         = "sql_mode"
    value        = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
  }
  parameter {
    apply_method = "pending-reboot"
    name         = "skip-character-set-client-handshake"
    value        = "1"
  }
}

data "aws_ssm_parameter" "admin_db_password" {
  name = "/chitchat/ADMIN_DB_PASSWORD"
}
