variable "security_group_name" {
  description = "SG name"
  type = string
  default = "terraform-example-instance"
}

variable "server_port" {
  description = "Web server Port number"
  type = number
  default = 8080
}
