# Creazione modello di lancio
resource "aws_launch_template" "lt" {
  depends_on             = [aws_ami_from_instance.ami-wp]
  name_prefix            = "wp-lt"
  image_id               = data.aws_ami.image.id
  instance_type          = var.ec2_instance_type
  key_name               = aws_key_pair.bastion-key.key_name
  vpc_security_group_ids = [aws_default_security_group.default.id, aws_security_group.web.id]
}

# Creazione gruppo autoscaling
resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = [aws_subnet.sub-private-a.id, aws_subnet.sub-private-b.id]
  desired_capacity    = "2"
  max_size            = "4"
  min_size            = "2"

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 2
      on_demand_percentage_above_base_capacity = 100
      spot_allocation_strategy                 = "capacity-optimized"
    }
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.lt.id
      }


    }
  }
  tags = [{
    "Name" = "value"
  }]
}

# Associazione bilanciatore al gruppo autoscaling
resource "aws_autoscaling_attachment" "asg_attachment_alb" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  alb_target_group_arn   = aws_alb_target_group.group.arn
}

# Autoscaling Policy
resource "aws_autoscaling_policy" "asg-policy-scale-up" {
  policy_type               = "StepScaling"
  name                      = "Scale UP"
  adjustment_type           = "ChangeInCapacity"
  autoscaling_group_name    = aws_autoscaling_group.asg.name
  estimated_instance_warmup = "60"

  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0
  }
}

resource "aws_autoscaling_policy" "asg-policy-scale-down" {
  policy_type              = "StepScaling"
  name                     = "Scale DOWN"
  adjustment_type          = "PercentChangeInCapacity"
  autoscaling_group_name   = aws_autoscaling_group.asg.name
  min_adjustment_magnitude = "1"

  step_adjustment {
    scaling_adjustment          = -25
    metric_interval_upper_bound = 0
  }
}

# Allarmi CloudWatch 
resource "aws_cloudwatch_metric_alarm" "alarm-cpu-high" {
  alarm_name          = "EC2 allarme utilizzo cpu alta"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_actions = [aws_autoscaling_policy.asg-policy-scale-up.arn]
}

resource "aws_cloudwatch_metric_alarm" "alarm-cpu-low" {
  alarm_name          = "EC2 allarme utilizzo cpu basso"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "5"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_actions = [aws_autoscaling_policy.asg-policy-scale-down.arn]
}
