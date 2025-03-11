#|||||||||||||INSTANCIAS DEL FRONTEND||||||||||||||||||
resource "aws_launch_template" "launch_template_front" {
  name_prefix   = "lt-front"
  image_id      = "ami-05b10e08d247fb927"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_ec2_public.id]
  user_data = base64encode(templatefile("./scripts/userdatafront.sh",{url_internal_lb=aws_lb.back_lb.dns_name}))
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg_front" {
  desired_capacity   = 1
  max_size           = var.max_amount_ec2
  min_size           = 1
  vpc_zone_identifier = var.public_subnets_id
  health_check_grace_period = 300
  health_check_type         = "EC2"

  launch_template {
    id      = aws_launch_template.launch_template_front.id
    version = "$Latest"
  }
}

resource "aws_security_group" "sg_external_lb" {
  name = "SG external load balancer"
  description = "Security group del Load Balancer externo"
  vpc_id = var.vpc_id

  ingress {
    protocol = "TCP"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Owner = "Bruno"
  }
}

resource "aws_security_group" "sg_ec2_public" {
  name = "SG public subnets"
  description = "Security group de las instancias ec2 desplegadas en subredes publicas"
  vpc_id = var.vpc_id

  ingress {
    protocol = "TCP"
    from_port = 80
    to_port = 80
    security_groups = [ aws_security_group.sg_external_lb.id ]
  }

  ingress {
    protocol = "TCP"
    from_port = 22
    to_port = 22
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Owner = "Bruno"
  }
}

resource "aws_lb" "front_lb" {
  name               = "front-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_external_lb.id]
  subnets            = var.public_subnets_id

  depends_on = [ aws_lb.back_lb ]

  tags = {
    Owner = "Bruno"
    Env = "dev"
  }
}

resource "aws_lb_target_group" "tg_front" {
  name        = "tg-front"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
}

resource "aws_autoscaling_attachment" "tg_front_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg_front.id
  lb_target_group_arn    = aws_lb_target_group.tg_front.arn
}

resource "aws_lb_listener" "listener_front" {
  load_balancer_arn = aws_lb.front_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_front.arn
  }
}

resource "aws_autoscaling_policy" "front_scale_up" {
  name                   = "front_scale_up"
  autoscaling_group_name = aws_autoscaling_group.asg_front.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "front_scale_up" {
  alarm_description   = "Se monitorea el CPU de las instancias del Frontend"
  alarm_actions       = [aws_autoscaling_policy.front_scale_up.arn]
  alarm_name          = "alarm_front_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "70"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_front.name
  }
}

resource "aws_autoscaling_policy" "front_scale_down" {
  name                   = "front_scale_down"
  autoscaling_group_name = aws_autoscaling_group.asg_front.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "front_scale_down" {
  alarm_description   = "Se monitorea el CPU de las instancias del Frontend"
  alarm_actions       = [aws_autoscaling_policy.front_scale_down.arn]
  alarm_name          = "alarm_front_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "30"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_front.name
  }
}


#|||||||||||INSTANCIAS DEL BACKEND||||||||||||||||||||||
resource "aws_launch_template" "launch_template_back" {
  name_prefix   = "lt-back"
  image_id      = "ami-05b10e08d247fb927"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_ec2_private.id]
  user_data = filebase64("./scripts/userdataback.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg_back" {
  desired_capacity   = 1
  max_size           = var.max_amount_ec2
  min_size           = 1
  vpc_zone_identifier = var.private_subnets_id
  health_check_grace_period = 300
  health_check_type         = "EC2"
  //target_group_arns = [ aws_lb_target_group.tg_back.arn ]

  launch_template {
    id      = aws_launch_template.launch_template_back.id
    version = "$Latest"
  }
}

resource "aws_security_group" "sg_internal_lb" {
  name = "SG internal load balancer"
  description = "Security group del Load Balancer interno"
  vpc_id = var.vpc_id

  ingress {
    protocol = "TCP"
    from_port = 80
    to_port = 80
    security_groups = [ aws_security_group.sg_ec2_public.id ]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Owner = "Bruno"
  }
}

resource "aws_security_group" "sg_ec2_private" {
  name = "SG private subnets"
  description = "Security group de las instancias ec2 en las subredes privadas del back"
  vpc_id = var.vpc_id

  ingress {
    protocol = "TCP"
    to_port = 3000
    from_port = 3000
    security_groups = [ aws_security_group.sg_internal_lb.id ]
  }

  egress {
    protocol = "-1"
    to_port = 0
    from_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Owner = "Bruno"
  }
}

resource "aws_lb" "back_lb" {
  name               = "back-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_internal_lb.id]
  subnets            = var.private_subnets_id

  tags = {
    Owner = "Bruno"
    Env = "dev"
  }
}

resource "aws_lb_target_group" "tg_back" {
  name        = "tg-back"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled = true
    path     = "/health"
  }
}

resource "aws_autoscaling_attachment" "tg_back_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg_back.name
  lb_target_group_arn    = aws_lb_target_group.tg_back.arn
}

resource "aws_lb_listener" "listener_back" { 
  load_balancer_arn = aws_lb.back_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_back.arn
  }
}

resource "aws_autoscaling_policy" "back_scale_up" {
  name                   = "back_scale_up"
  autoscaling_group_name = aws_autoscaling_group.asg_back.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "back_scale_up" {
  alarm_description   = "Se monitorea el CPU de las instancias del Backend"
  alarm_actions       = [aws_autoscaling_policy.back_scale_up.arn]
  alarm_name          = "alarm_back_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "75"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_back.name
  }
}

resource "aws_autoscaling_policy" "back_scale_down" {
  name                   = "back_scale_down"
  autoscaling_group_name = aws_autoscaling_group.asg_back.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "back_scale_down" {
  alarm_description   = "Se monitorea el CPU de las instancias del Backend"
  alarm_actions       = [aws_autoscaling_policy.back_scale_down.arn]
  alarm_name          = "alarm_back_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "50"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_back.name
  }
}