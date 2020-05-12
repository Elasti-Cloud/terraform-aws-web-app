profile          = "AWS_PROFILE_NAME"
region           = "us-west-1"
admin_ip         = "HOME IP or RANGE cidr - 120.120.120.120/32"
s3_bucket_source = "S3-BUCKET-NAME-WHITH-CODE"
vpc_cidr         = "10.30.0.0/16"
subnet_cidr = {
  public01  = "10.30.0.0/20"
  public02  = "10.30.16.0/20"
  private01 = "10.30.64.0/20"
  private02 = "10.30.80.0/20"
}
ami = {
  application = "ami-06fcc1f0bc2c8943f"
  bastion     = "ami-06fcc1f0bc2c8943f"
  jenkins     = "ami-0f56279347d2fa43e"
}
instance_type = {
  application = "t3.micro"
  bastion     = "t3.micro"
  jenkins     = "t3.micro"
}
key_name = {
  application = "AWS-KEY-PAIR-NAME"
  bastion     = "AWS-KEY-PAIR-NAME"
  jenkins     = "AWS-KEY-PAIR-NAME"
}

tags = {
  Name        = "Terraform"
  Tool        = "Terraform"
  Environment = "dev"
}

asg_param = {
  max_size         = 2
  min_size         = 1
  desired_capacity = 1
}

iam_policies_arn_jenkins = [
  "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  "arn:aws:iam::aws:policy/CloudWatchFullAccess",
  "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
]