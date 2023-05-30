#### VPC 생성 ####
variable "vpc_cidr" {
  description = "VPC CIDR"
  type = string
  default = "10.0.0.0/16"
}

variable "instance_tenancy" {
  description = "Instance tenancy"
  type = string
  default = "default"
}

variable "vpc_tag" {
  description = "VPC tag"
  type = map(string)
  default = {
    "Name" = "main"
  }
}
#### Subnet 생성 ####
variable "vpc_id" {
 description = "VPC ID"
 type = string 
}

variable "subnet_cidr_block" {
  description = "Subnet CIDR"
  type = string
  default = "10.0.1.0/24"
}

variable "subnet_tag" {
  description = "Subnet tag"
  type = map(string)
  default = {
    "Name" = "main"
  }
}

output "vpc_id" {
  description = "VPC ID"
  value = aws_vpc.main.id
}

output "subnet_id" {
  description = "Subnet ID"
  value = aws_subnet.main.id
}