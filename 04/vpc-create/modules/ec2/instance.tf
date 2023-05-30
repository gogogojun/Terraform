#### Instance 생성 ####
resource "aws_instance" "web" {
  count = var.ec2_count
  
  ami           = var.ami_id_AmazonLinux2023
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  tags = var.instance_tag
}