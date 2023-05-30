terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "myInstanceSG" {
  name        = "myInstanceSG"
  description = "Allow HTTP(8080/tcp)"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP(8080/tcp)"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-01"
    cidr_blocks = ["0.0.0.0/0"]


  }
  tags = {
    Name = "MyInstanceSG"
  }
}

data "terraform_remote_state" "myRemoteState" {
  backend = "s3"
  config = {
    bucket = "bucket-gjh-98585488"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"
  }

}

resource "aws_launch_configuration" "my_launch" {
  name          = "myLaunchConfiguration"
  image_id      = "ami-06c4532923d4ba1ec"
  instance_type = "t2.micro"

  security_groups = [aws_security_group.myInstanceSG.id]
  user_data = templatefile("userdata.sh", {
    server_port = 8080

    db_address = data.terraform_remote_state.myRemoteState.outputs.address
    db_port    = data.terraform_remote_state.myRemoteState.outputs.port
  })
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "myALB-TG" {
  name     = "myALB-TG"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_autoscaling_group" "MyASG" {
  launch_configuration = aws_launch_configuration.my_launch.name
  vpc_zone_identifier  = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.myALB-TG.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "myASG"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "myALB-SG" {
  name        = "myALB-SG"
  description = "Allow HTTP(80/tcp)"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow HTTP(80/tcp)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-01"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "myALB-SG"
  }
}

resource "aws_lb" "myALB" {
  name               = "myALB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.myALB-SG.id]
  subnets            = data.aws_subnets.default.ids

  tags = {
    Name = "myALB"
  }
}

resource "aws_lb_listener" "myALB-Listner" {
  load_balancer_arn = aws_lb.myALB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "myALB-Listner-Rule" {
  listener_arn = aws_lb_listener.myALB-Listner.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myALB-TG.arn
  }
}