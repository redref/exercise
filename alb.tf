# ALB Security group
# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "lb" {
  name        = "httpbin-alb"
  description = "controls access to the ALB"
  vpc_id      = aws_vpc.exercise_vpc.id
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "httpbin-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id      = aws_vpc.exercise_vpc.id
  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = ["${aws_security_group.lb.id}"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "httpbin" {
  name            = "httpbin-alb"
  subnets         = aws_subnet.public[*].id
  security_groups = ["${aws_security_group.lb.id}"]
}

resource "aws_alb_target_group" "httpbin" {
  name        = "httpbin"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.exercise_vpc.id
  target_type = "ip"
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "httpbin_listener" {
  load_balancer_arn = aws_alb.httpbin.id
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.httpbin.id
    type             = "forward"
  }
}
