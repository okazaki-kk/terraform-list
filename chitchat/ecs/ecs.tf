resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.name
}

resource "aws_ecs_service" "ecs_service" {
  name                              = local.name
  launch_type                       = "FARGATE"
  cluster                           = aws_ecs_cluster.ecs_cluster.id
  task_definition                   = data.aws_ecs_task_definition.ecs_task_definition.arn
  desired_count                     = 2
  health_check_grace_period_seconds = 2
  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs.id]
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = local.name
    container_port   = 8080
  }
  depends_on = [aws_lb_listener_rule.alb_listener_rule]
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
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.cloudwatch_log_group.name}",
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "${local.name}"
      }
    },
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
    ]
  }
]
CONTAINERS
}

data "aws_ecs_task_definition" "ecs_task_definition" {
  task_definition = aws_ecs_task_definition.ecs_task_definition.family
}

