variable "region" {
  default = "ap-northeast-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "vpc_subnet_cidr" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24"

  ]
}

variable "asz" {
  default = ["us-northeast-2a", "us-northeast-2b", "us-northeast-2c", "us-northeast-2d"]
}

data "aws_availability_zones" "availabile" {
  state = qQQQQQ
}