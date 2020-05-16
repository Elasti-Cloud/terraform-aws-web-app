variable "vpc_id" {
  description = "VPC"
  type        = string
}

variable "subnets_list" {
  description = "List of subnets: 2 public and 2 private"
}

variable "security_group" {
  description = "Dict of Security Groups"
}

variable "ec2_profile" {
  description = "Dict of Instance Profiles"
}

variable "app_lb" {
  description = "Reference to ELB"
}

variable "inst_params" {
  description = "AMIs to use. Make sure to align with a region"
}

variable "tags" {
  description = "Dictionary of tags"
  type        = map(string)
}