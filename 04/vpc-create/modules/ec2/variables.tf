#### EC2 인스턴스 ####
variable "ec2_count" {
  description = "EC2 count"
  type = number
  default = 2
}

variable "ami_id_AmazonLinux2023" {
  description = "(Seoul Region)ami_id_AmazonLinux2023"
  type = string
  default = "ami-03f54df9441e9b380"
}

variable "instance_type" {
  description = "Instance Type"
  type = string
  default = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID"
  type = string
}


variable "instance_tag" {
    description = "Instance tag"
    type = map(string)
    default = {
        "Name" = "main"
    }
}