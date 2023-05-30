provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_vpc" "akbun-vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "t101-study"
  }
}

resource "aws_subnet" "akbun-subnet1" {
  vpc_id     = aws_vpc.akbun-vpc.id
  cidr_block = "10.10.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "t101-subnet1"
  }
}

resource "aws_subnet" "akbun-subnet2" {
  vpc_id     = aws_vpc.akbun-vpc.id
  cidr_block = "10.10.2.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "t101-subnet2"
  }
}

resource "aws_internet_gateway" "akbun-igw" {
  vpc_id = aws_vpc.akbun-vpc.id

  tags = {
    Name = "t101-igw"
  }
}

# route table 생성
resource "aws_route_table" "akbun-rt" {
  vpc_id = aws_vpc.akbun-vpc.id

  tags = {
    Name = "t101-rt"
  }
}

# route table과 subnet 연결
resource "aws_route_table_association" "akubun-rt-association1" {
  subnet_id      = aws_subnet.akbun-subnet1.id
  route_table_id = aws_route_table.akbun-rt.id
}

# route table과 subnet 연결
resource "aws_route_table_association" "akubun-rt-association2" {
  subnet_id      = aws_subnet.akbun-subnet2.id
  route_table_id = aws_route_table.akbun-rt.id
}

# route 규칙 추가
resource "aws_route" "mydefaultroute" {
  route_table_id         = aws_route_table.akbun-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.akbun-igw.id
}

resource "aws_security_group" "akbun-mysg" {
  vpc_id      = aws_vpc.akbun-vpc.id
  name        = "T101 SG"
  description = "T101 Study SG"
}

resource "aws_security_group_rule" "mysginbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.akbun-mysg.id
}

resource "aws_security_group_rule" "mysgoutbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.akbun-mysg.id
}

resource "aws_lb" "akbun-alb" {
  name               = "t101-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.akbun-subnet1.id, aws_subnet.akbun-subnet2.id]
  security_groups    = [aws_security_group.akbun-mysg.id]

  tags = {
    Name = "t101-alb"
  }
}

resource "aws_lb_listener" "myhttp" {
  load_balancer_arn = aws_lb.akbun-alb.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found - T101 Study"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "akbun-tg" {
  name     = "t101-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.akbun-vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 5
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "akbun-albrule" {
  listener_arn = aws_lb_listener.myhttp.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.akbun-tg.arn
  }
}

output "akbunalb_dns" {
  value       = aws_lb.akbun-alb.dns_name
  description = "The DNS Address of the ALB"
}

resource "aws_autoscaling_group" "akbun-asg" {
  name                 = "myasg"
  launch_configuration = aws_launch_configuration.akbun-launchconfig.name
  vpc_zone_identifier  = [aws_subnet.akbun-subnet1.id, aws_subnet.akbun-subnet2.id]

  # ELB 연결
  health_check_type = "ELB"
  target_group_arns = [aws_lb_target_group.akbun-tg.arn]

  min_size = 2
  max_size = 4

  tag {
    key                 = "Name"
    value               = "terraform-asg"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "akbun-launchconfig" {
  name_prefix                 = "t101-lauchconfig-"
  image_id                    = data.aws_ami.my_amazonlinux2.id
  instance_type               = "t2.nano"
  security_groups             = [aws_security_group.akbun-mysg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              wget https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64
              mv busybox-x86_64 busybox
              chmod +x busybox
              RZAZ=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone-id)
              IID=$(curl 169.254.169.254/latest/meta-data/instance-id)
              LIP=$(curl 169.254.169.254/latest/meta-data/local-ipv4)
              echo "<h1>RegionAz($RZAZ) : Instance ID($IID) : Private IP($LIP) : Web Server</h1>" > index.html
              nohup ./busybox httpd -f -p 80 &
              EOF

  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami" "my_amazonlinux2" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}