resource "aws_kms_key" "httpbin_kms" {
  description             = "httpbin_kms"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "httpbin_log_group" {
  name = "httpbin_log_group"
}

resource "aws_ecs_cluster" "httpbin" {
  name = "httpbin"

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.httpbin_kms.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.httpbin_log_group.name
      }
    }
  }
}

resource "aws_ecs_task_definition" "httpbin" {
  family                   = "httpbin"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory

  container_definitions = jsonencode([
    {
      name        = "httpbin"
      image       = "${var.app_image}"
      cpu         = var.fargate_cpu,
      memory      = var.fargate_memory
      essential   = false
      networkMode = false
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "httpbin" {
  name            = "httpbin"
  cluster         = aws_ecs_cluster.httpbin.id
  task_definition = aws_ecs_task_definition.httpbin.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
    subnets         = aws_subnet.private[*].id
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.httpbin.id
    container_name   = "httpbin"
    container_port   = var.app_port
  }

  depends_on = [
    aws_alb_listener.httpbin_listener,
  ]

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_appautoscaling_target" "httpbin" {
  max_capacity       = var.app_count_max
  min_capacity       = var.app_count
  resource_id        = "service/${aws_ecs_cluster.httpbin.name}/${aws_ecs_service.httpbin.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"


  depends_on = [aws_ecs_service.httpbin]
}

resource "aws_appautoscaling_policy" "httpbin" {
  name               = "httpbin-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.httpbin.resource_id
  scalable_dimension = aws_appautoscaling_target.httpbin.scalable_dimension
  service_namespace  = aws_appautoscaling_target.httpbin.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.app_auto_scaling_max_cpu_util

    scale_in_cooldown  = 300
    scale_out_cooldown = 300

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }

  depends_on = [aws_appautoscaling_target.httpbin]
}
