# 環境変数でシークレットを渡す例
# export TF_VAR_db_username="myuser"
# export TF_VAR_db_password="mypassword" のようにして渡す
variable "db_username" {
  description = "value of the db username"
  type = string
  sensitive = true
}

variable "db_password" {
  description = "value of the db password"
  type = string
  sensitive = true
}

resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-secrets-env"
  engine = "mysql"
  allocated_storage = 20
  instance_class = "db.t2.micro"
  skip_final_snapshot = true
  db_name = "mydb"

  username = var.db_username
  password = var.db_password
}
