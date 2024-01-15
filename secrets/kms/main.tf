data "aws_iam_policy_document" "cmk_admin_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.self.arn]
    }
  }
}

resource "aws_kms_key" "cmk" {
  policy                  = data.aws_iam_policy_document.cmk_admin_policy.json
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "cmk" {
  name          = "alias/kms-cmk-example"
  target_key_id = aws_kms_key.cmk.id
}

data "aws_kms_secrets" "creds" {
  secret {
    name = "db"
    payload = file("${path.module}/db-pass.yaml.encrypted")
  }
}

locals {
  db_creds = yamldecode(data.aws_kms_secrets.creds.plaintext["db"])
}

resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-secrets-env"
  engine = "mysql"
  allocated_storage = 20
  instance_class = "db.t2.micro"
  skip_final_snapshot = true
  db_name = "mydb"

  username = local.db_creds.username
  password = local.db_creds.password
}
