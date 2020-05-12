variable "vpc_id" {
  description = "VPC"
  type        = string
}

variable "admin_ip" {
  description = "IP or IP range for the admin clients"
  type        = string
}

variable "tags" {
  description = "Dictionary of tags"
  type        = map(string)
}

variable "iam_policies_arn_jenkins" {
  description = "IAM Policies to be attached to instance role"
  type        = list
}