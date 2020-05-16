variable "network" {
  description = "CIDR for VPC, CIDRs for public and private subnets"
}

variable "tags" {
  description = "Dictionary of tags"
  type        = map(string)
}


