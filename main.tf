# Main configuration
terraform {
  required_version = ">=0.12.0"
}
# AWS Provider 
provider "aws" {
  version = "~> 2.0"
  profile = var.profile
  region  = var.region
}
# VPC, Subnets, IGW, NAT GW, RT public/private
module "aws_network" {
  source = "./modules/aws_network"

  region      = var.region
  vpc_cidr    = var.vpc_cidr
  subnet_cidr = var.subnet_cidr
  tags        = var.tags
}
# IAM roles, Security Groups
module "aws_security" {
  source = "./modules/aws_security"
  vpc_id = module.aws_network.vpc_id

  admin_ip                 = var.admin_ip
  tags                     = var.tags
  iam_policies_arn_jenkins = var.iam_policies_arn_jenkins
}
# ELB, ASG, LaunchTemplate, Jenkins server
module "aws_app_layer" {
  source         = "./modules/aws_app_layer"
  vpc_id         = module.aws_network.vpc_id
  subnets_list   = module.aws_network.subnets_list
  security_group = module.aws_security.security_group
  ec2_profile    = module.aws_security.ec2_profile

  s3_bucket_source = var.s3_bucket_source
  ami              = var.ami
  instance_type    = var.instance_type
  key_name         = var.key_name
  asg_param        = var.asg_param
  tags             = var.tags
}
# Bastion server for admin tasks
module "aws_admin" {
  source         = "./modules/aws_admin"
  subnets_list   = module.aws_network.subnets_list
  security_group = module.aws_security.security_group

  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  tags          = var.tags
}