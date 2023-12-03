# ECSタスクがロールをAssumeするためのポリシー
data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECSタスク用のロール
# TaskRole はタスク自体が利用するIAM Roleで、S3やSQSへのアクセスなどを制御する
resource "aws_iam_role" "ecs_task" {
  name               = "${local.name}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

# ECSがロールをAssumeするためのポリシー
data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS自体のロール
# execution role は ECS自体が利用するIAM Roleで、imageのpullやCloudWatchへのログの書き込みを行う
resource "aws_iam_role" "ecs" {
  name               = "${local.name}-ecs"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

resource "aws_iam_role_policy_attachment" "ecs_basic" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_custom" {
  name = "${local.name}-ecs-parameter"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
        ]
        Resource = [
          "${data.aws_ssm_parameter.admin_db_password.arn}"
        ]
      }
    ]
  })

  role = aws_iam_role.ecs.id
}
