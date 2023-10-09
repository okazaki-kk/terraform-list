resource "aws_ecr_repository" "ecr_repository" {
  name         = local.name
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

# イメージの数が20を超えたら古いものから削除するルール
resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  repository = aws_ecr_repository.ecr_repository.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 20 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 20
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
