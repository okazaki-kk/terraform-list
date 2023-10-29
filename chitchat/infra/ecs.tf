resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.name
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = local.name
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  # NOTE: このコンテナ定義は最新のものとは限らない。コンテナ定義は、Github ActionsのワークフローによりTerraformの外側で更新される。
  container_definitions = <<CONTAINERS
[
  {
    "name": "${local.name}",
    "image": "167855287371.dkr.ecr.ap-northeast-1.amazonaws.com/chitchat:latest",
    "portMappings": [
      {
        "hostPort": 8080,
        "containerPort": 8080,
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name": "MYSQL_HOST",
        "value": "chitchat.cwz2ti5k66tm.ap-northeast-1.rds.amazonaws.com"
      }
    ],
    "secrets": [
      {
        "name": "MYSQL_PASSWORD",
        "valueFrom": "${data.aws_ssm_parameter.admin_db_password.arn}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.cloudwatch_log_group.name}",
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "${local.name}"
      }
    }
  }
]
CONTAINERS
}
