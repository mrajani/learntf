provider "aws" {
  region  = var.region
  version = "~> 2.20"
}

resource "aws_lb" "fe_lb" {
  name               = format("%s-loadbalancer", var.tags["Name"])
  internal           = false
  load_balancer_type = "application"
  subnets            = slice(data.terraform_remote_state.current.outputs.public_subnet_id, 0, 3)
  security_groups    = [aws_security_group.sg_lb.id]

  tags = merge(var.tags, map("Name", format("%s-lb-asg", var.tags["Name"])))
}


resource "aws_security_group" "sg_lb" {
  vpc_id      = data.terraform_remote_state.current.outputs.vpc_id
  name        = format("%s-sg-lb", var.tags["Name"])
  description = "Security group for web access to VPC"
  # web access from anywhere
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
  vpc_id      = data.terraform_remote_state.current.outputs.vpc_id
  name        = format("%s-sg-lt", var.tags["Name"])
  description = "Security group for Ec2 Launch Template"
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
  name     = "${var.tags["Name"]}-alb-tg"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.current.outputs.vpc_id
  tags     = merge(var.tags, map("Name", format("%s-lb-tg", var.tags["Name"])))

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }
}

resource "aws_launch_template" "ec2web" {
  name          = "${var.tags["Name"]}-alb-lt"
  image_id      = "ami-0c6b1d09930fac512"
  instance_type = "t2.micro"
  key_name      = "${var.name}-key"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
    }
  }

  instance_initiated_shutdown_behavior = "terminate"
  monitoring {
    enabled = true
  }

  vpc_security_group_ids = [aws_security_group.sg_lt.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }
  tags      = merge(var.tags, map("Name", format("%s-lb-asg", var.tags["Name"])))
  user_data = "${base64encode("#!/bin/bash\n echo hello world")}"
}

resource "aws_autoscaling_group" "ec2web" {
  name                = "${var.tags["Name"]}-asg-ec2web"
  desired_capacity    = 2
  max_size            = 6
  min_size            = 2
  target_group_arns   = [aws_lb_target_group.lb_tg.arn]
  vpc_zone_identifier = slice(data.terraform_remote_state.current.outputs.public_subnet_id, 0, 3)

  launch_template {
    id      = "${aws_launch_template.ec2web.id}"
    version = "$Latest"
  }

  tags = concat(
    list(
      map("key", "Name", "value", "${var.tags["Name"]}", "propagate_at_launch", true),
      map("key", "AccountId", "value", "${var.tags["AccountId"]}", "propagate_at_launch", true),
      map("key", "Environment", "value", "${var.tags["Environment"]}", "propagate_at_launch", true),
      map("key", "RandomCode", "value", "${var.tags["RandomCode"]}", "propagate_at_launch", true)
    ),
    var.asg_tags
  )

  enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupTotalInstances"]

}

variable "asg_tags" {
  default = [
    {
      key                 = "Test"
      value               = "Passed"
      propagate_at_launch = true
    },
  ]
}

resource "aws_autoscaling_policy" "scaleout" {
  name                   = "ScaleOut"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.ec2web.name}"
}

resource "aws_cloudwatch_metric_alarm" "highcpu" {
  alarm_name          = "HighCPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.ec2web.name}"
  }

  alarm_description = "This metric monitor EC2 instance cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.scaleout.arn}"]
}

#
resource "aws_autoscaling_policy" "scaleback" {
  name                   = "ScaleBack"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.ec2web.name}"
}

resource "aws_cloudwatch_metric_alarm" "lowcpu" {
  alarm_name          = "LowCPU"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "5"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.ec2web.name}"
  }

  alarm_description = "This metric monitor EC2 instance cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.scaleback.arn}"]
}

