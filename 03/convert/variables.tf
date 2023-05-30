variable "myregion" {
  description = "My Work space - region"
  type        = string
  default     = "us-east-2"
}

variable "myvpccidr" {
  description = "My VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "myVPCtag" {
  description = "My VPC Tag"
  type        = map(any)
  default     = { Name = "My-VPC" }
}

variable "myIGWtag" {
  description = "My IGW tag"
  type        = map(any)
  default     = { Name = "My-IGW" }
}

variable "ALLNetwork" {
  description = "All network is 0.0.0.0/0"
  type        = string
  default     = "0.0.0.0/0"
}

variable "myPublicRTTag" {
  description = "My Public Routing Table Tag"
  type        = map(any)
  default     = { Name = "My-Public-RT" }
}