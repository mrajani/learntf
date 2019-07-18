resource "aws_lb" "fe_lb" {
  name               = "lb-autoscaler"
  internal           = false
  load_balancer_type = "application"
  subnets            = slice(aws_subnet.public.*.id, 0, 3)
  security_groups    = [aws_security_group.sg_lb.id]

  tags = merge(var.tags, map("Name", format("%s-lb-asg", var.tags["Name"])))
}


resource "aws_security_group" "sg_lb" {
  vpc_id      = aws_vpc.main.id
  name        = format("%s-sg-lb", var.tags["Name"])
  description = "SG for External Access to VPC"
  # SSH access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, map("Name", format("%s-sg-lb", var.tags["Name"])))

}

resource "aws_security_group" "sg_lt" {
  vpc_id      = aws_vpc.main.id
  name        = format("%s-sg-lt", var.tags["Name"])
  description = "SG for Ec2 Launch Template"
  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.sg_lb.id}"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, map("Name", format("%s-sg-lt", var.tags["Name"])))

}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = "${aws_lb.fe_lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.lb_tg.arn}"
  }
}

resource "aws_lb_target_group" "lb_tg" {
  name     = "alb-target-group"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  tags     = merge(var.tags, map("Name", format("%s-sg-lt", var.tags["Name"])))

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
  }
}

