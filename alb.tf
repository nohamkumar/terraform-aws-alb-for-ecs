resource "aws_lb" "alb" {
  name               = "${module.this.id}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups = compact(
    concat(var.additional_security_groups, [aws_security_group.alb.id]),
  )

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    enabled = true
  }

  depends_on = [
    aws_s3_bucket.alb_logs
  ]

  tags = merge(
    module.this.tags,
    {
      Name = "${module.this.id}-alb"
    },
  )
}

#-----
#LISTENERS
#-----

resource "aws_lb_listener" "http" {
  count = var.http_listener_enabled == true ? 1 : 0

  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn

  port            = 443
  protocol        = "HTTPS"
  ssl_policy      = var.ssl_policy
  certificate_arn = var.default_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_https_tg.arn
  }
}

#----------
#TARGET GROUPS
#----------

resource "aws_lb_target_group" "alb_https_tg" {

  name        = module.this.id
  port        = var.target_group_port
  protocol    = "HTTPS"
  vpc_id      = var.vpc_id
  target_type = "ip"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }

  health_check {
    path     = var.target_group_health_check_path
    protocol = "HTTP"
    matcher  = 200
  }

  tags = merge(
    module.this.tags,
    {
      Name = "${module.this.id}"
    }
  )

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb.alb]
}
