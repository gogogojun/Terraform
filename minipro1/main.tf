# VPC 생성
resource "aws_vpc" "gjh_vpc" {
  cidr_block = "10.123.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

# Subnet 생성
resource "aws_subnet" "gjh_public_subnet" {
  vpc_id     = aws_vpc.gjh_vpc.id
  cidr_block = "10.123.1.0/24"

  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-public"
  }
}

# IGW 생성
resource "aws_internet_gateway" "gjh_IGW" {
  vpc_id = aws_vpc.gjh_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

# Routing Table 설정
resource "aws_route_table" "gjh_public_rt" {
  vpc_id = aws_vpc.gjh_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gjh_IGW.id
  }

  tags = {
    Name = "dev_public_rt"
  }
}

# Routing Table <- association -> Subnet
resource "aws_route_table_association" "gjh_public_rt_assoc" {
  subnet_id      = aws_subnet.gjh_public_subnet.id
  route_table_id = aws_route_table.gjh_public_rt.id
}

# Security Group 생성
resource "aws_security_group" "gjh_SG" {
  name        = "allow_web_ssh"
  description = "Allow HTTP, HTTPS, SSH"
  vpc_id      = aws_vpc.gjh_vpc.id

  ingress {
    description = "Allow HTTP inbound traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP inbound traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS inbound traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH inbound traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web_ssh"
  }
}

data "aws_ami" "ubuntu2004" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}
resource "aws_key_pair" "gjh_auth" {
  key_name   = "gjhkey"
  public_key = file("~/.ssh/gjh.key.pub")
}
resource "aws_instance" "dev-webserver" {
  ami                    = data.aws_ami.ubuntu2004.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.gjh_SG.id]

  key_name = aws_key_pair.gjh_auth.id

  subnet_id = aws_subnet.gjh_public_subnet.id

  user_data                   = file("userdata.tpl")
  user_data_replace_on_change = true
  provisioner "local-exec" {
    command = templatefile("linux-ssh-config.tpl"
    ,{hostname = self.public_ip,
     user = "ubuntu",
     identifyfile = "~/.ssh/gjh.key"})
    interpreter = [ "bash", "-c" ]
  }
  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "my dev web server"
  }
}