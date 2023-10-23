data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "allow_dynamodb" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:UpdateItem",
      "dynamodb:Scan",
      "dynamodb:Query",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.book.name}",
    ]
  }
}

resource "aws_iam_policy" "templatefile" {
  name = "templatefile"
  policy = templatefile("./policy.json", {
    region = data.aws_region.current.name,
    account_id = data.aws_caller_identity.current.account_id,
    table_name = aws_dynamodb_table.book.name
  })
}

resource "aws_dynamodb_table" "book" {
  name     = "Books"
  hash_key = "id"
  attribute {
    name = "id"
    type = "N"
  }
  billing_mode = "PAY_PER_REQUEST"
}

output "aws_region" {
  value = data.aws_region.current.name
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_iam_policy" {
  value = aws_iam_policy.templatefile.policy
}

output "aws_iam_policy_document" {
  value = data.aws_iam_policy_document.allow_dynamodb.json
}
