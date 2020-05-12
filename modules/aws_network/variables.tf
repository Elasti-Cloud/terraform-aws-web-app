variable "region" {
  description = "AWS region"
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "List of subnets 2 public and 2 private"
  type        = map(string)
}

variable "tags" {
  description = "Dictionary of tags"
  type        = map(string)
}


