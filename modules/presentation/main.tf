# Route Table Association
resource "aws_route_table_association" "association" {
  subnet_id      = var.presentation_subnet_id
  route_table_id = var.route_table_id
}

resource "aws_lb" "alb" {
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.presentation_alb_sg_id]
  subnets                    = [var.presentation_subnet_id]
  enable_deletion_protection = true

  tags = {
    Name = "3Tier-ALB"
  }
}

resource "aws_lb_target_group" "tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = var.enable_stickiness
  }

  health_check {
    interval            = var.health_check_interval
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = var.health_check_protocol
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    matcher             = var.matcher
  }

  tags = {
    Name = "3Tier-TG"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = aws_lb.alb.arn
  }

  tags = {
    Name = "3Tier-ALB-listener"
  }
}

# Launch Template for Presentation Tier
resource "aws_launch_template" "presentation_lt" {
  image_id      = var.presentation_ami
  instance_type = var.presentation_ec2_type

  block_device_mappings {
    device_name = var.presentation_dev_name

    ebs {
      volume_size = var.presentation_vol_size
      volume_type = var.presentation_vol_type
    }
  }

  vpc_security_group_ids = [var.presentation_instance_sg_id]
  key_name               = var.presentation_key # Replace with your key pair name for SSH access
  # user_data              = file("presentation_user_data.sh") # Path to a user data script, if needed

  tags = {
    Name = "3Tier-Presentation-LT"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "presentation_asg" {
  launch_configuration = aws_launch_template.presentation_lt.id
  min_size             = var.presentation_asg_min
  max_size             = var.presentation_asg_max
  vpc_zone_identifier  = [var.presentation_subnet_id]

  launch_template {
    id = aws_launch_template.presentation_lt.id
  }

  tag {
    key                 = "Name"
    value               = "3Tier-Presentation-ASG"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "presentation_scale_out_policy" {
  name                   = "presentation-scale-out-policy"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.presentation_asg.name
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_autoscaling_policy" "presentation_scale_in_policy" {
  name                   = "presentation-scale-in-policy"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.presentation_asg.name
  scaling_adjustment     = -1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "presentation_high_cpu_alarm" {
  alarm_name          = "presentation-high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.presentation_max_threshold
  alarm_description   = "Alarm when CPU utilization is high"
  alarm_actions       = [aws_autoscaling_policy.presentation_scale_out_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.presentation_asg.name
  }

  tags = {
    Name = "3Tier-Presentation-CPU-metric-high"
  }
}

resource "aws_cloudwatch_metric_alarm" "presentation_low_cpu_alarm" {
  alarm_name          = "presentation-low-cpu-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.presentation_min_threshold
  alarm_description   = "Alarm when CPU utilization is low"
  alarm_actions       = [aws_autoscaling_policy.presentation_scale_in_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.presentation_asg.name
  }

  tags = {
    Name = "3Tier-Presentation-CPU-metric-low"
  }
}
