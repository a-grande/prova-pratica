# Creazione load balancer applicativo
resource "aws_alb" "wp-elb" {
  name               = "frontend-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_default_security_group.default.id, aws_security_group.web.id]
  subnets            = [aws_subnet.sub-public-a.id, aws_subnet.sub-public-b.id]

}

# Creazione target group
resource "aws_alb_target_group" "group" {
  name     = "frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.wordpress-vpc.id

  health_check {
    path = "/"
    port = 80
  }
}

# Creazione regola inoltro del bilanciatore verso il group target
resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.wp-elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.group.arn
    type             = "forward"
  }
}
