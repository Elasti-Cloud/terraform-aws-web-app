profile          = "ENTER-AWS-PROFILE-NAME"
region           = "us-east-1"
admin_ip         = "ENTER HOME IP or RANGE cidr - 120.120.120.120/32"
s3_bucket_source = "ENTER-S3-BUCKET-NAME-WHITH-CODE"

network = {
  vpc_cidr = "10.30.0.0/16"
  public_cidr = {
    0 = "10.30.0.0/20"
    1 = "10.30.16.0/20"
  }
  private_cidr = {
    0 = "10.30.64.0/20"
    1 = "10.30.80.0/20"
  }
}

inst_params = {
  ami = {
    application = "ami-0323c3dd2da7fb37d"
    bastion     = "ami-0323c3dd2da7fb37d"
    jenkins     = "ami-085925f297f89fce1"
  }

  type = {
    application = "t3.micro"
    bastion     = "t3.micro"
    jenkins     = "t3.micro"
  }

  key_name = {
    application = "ENTER-AWS-KEY-PAIR-NAME"
    bastion     = "ENTER-AWS-KEY-PAIR-NAME"
    jenkins     = "ENTER-AWS-KEY-PAIR-NAME"
  }
}

tags = {
  Name        = "Terraform"
  Tool        = "Terraform"
  Environment = "dev"
}

asg_params = {
  max_size         = 2
  min_size         = 1
  desired_capacity = 1
}

iam_policies_arn_jenkins = [
  "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  "arn:aws:iam::aws:policy/CloudWatchFullAccess",
  "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
]