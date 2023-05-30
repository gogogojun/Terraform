provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name     = "Main"
    Location = "Seoul"
  }
}


resource "aws_subnet" "subnets" {
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.vpc_subnet_cidr, count.index)

  count = length(var.asz)
  tags = {
    Name = "subnets-${count.index}"
  }
}
