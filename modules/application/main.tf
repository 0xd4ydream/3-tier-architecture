# Create Launch Template for Application Tier
resource "aws_launch_template" "application_lt" {
  image_id      = var.application_ami
  instance_type = var.application_ec2_type

  block_device_mappings {
    device_name = var.application_dev_name

    ebs {
      volume_size = var.application_vol_size
      volume_type = var.application_vol_type
    }
  }

  vpc_security_group_ids = [var.application_instance_sg_id]
  key_name               = var.application_key
  # user_data              = file("application_user_data.sh") # Path to a user data script, if needed

  tags = {
    Name = "3Tier-Application-LT"
  }
}

# Create Auto Scaling Group for Application Tier
resource "aws_autoscaling_group" "application_asg" {
  min_size            = var.application_asg_min
  max_size            = var.application_asg_max
  vpc_zone_identifier = [var.application_subnet_id]

  launch_template {
    id = aws_launch_template.application_lt.id
  }

  tag {
    key                 = "Name"
    value               = "3Tier-Application-ASG"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "application_scale_out_policy" {
  name                   = "application-scale-out-policy"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.application_asg.name
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_autoscaling_policy" "application_scale_in_policy" {
  name                   = "application-scale-in-policy"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.application_asg.name
  scaling_adjustment     = -1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "application_high_cpu_alarm" {
  alarm_name          = "application-high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.application_max_threshold
  alarm_description   = "Alarm when CPU utilization is high"
  alarm_actions       = [aws_autoscaling_policy.application_scale_out_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.application_asg.name
  }

  tags = {
    Name = "3Tier-Application-CPU-metric-high"
  }
}

resource "aws_cloudwatch_metric_alarm" "application_low_cpu_alarm" {
  alarm_name          = "application-low-cpu-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.application_min_threshold
  alarm_description   = "Alarm when CPU utilization is low"
  alarm_actions       = [aws_autoscaling_policy.application_scale_in_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.application_asg.name
  }

  tags = {
    Name = "3Tier-Application-CPU-metric-low"
  }
}
