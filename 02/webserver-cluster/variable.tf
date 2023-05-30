variable "server_port" {
  description = "Web Server Port"
  type        = number
  default     = 8080
}

variable "alb_name" {
  description = "ALB Name"
  type        = string
  default     = "terraform-asg-example"
}

variable "instance_security_group_name" {
  description = "SG Name for EC2"
  type        = string
  default     = "terraform-example-ec2"
}

variable "alb_security_group_name" {
  description = "ALB SG Name"
  type        = string
  default     = "terraform-example-alb"
}