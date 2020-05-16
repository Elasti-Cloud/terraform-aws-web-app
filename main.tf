# Main configuration
terraform {
  required_version = ">=0.12.6"
}
# AWS Provider 
provider "aws" {
  version = ">=2.5"
  profile = var.profile
  region  = var.region
}
# VPC, Subnets, IGW, NAT GW, RT public/private
module "aws_network" {
  source = "./modules/aws_network"

  network = var.network
  tags    = var.tags
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
  inst_params      = var.inst_params
  asg_params       = var.asg_params
  tags             = var.tags
}
# Jenkins server
module "aws_jenkins" {
  source         = "./modules/aws_jenkins"
  vpc_id         = module.aws_network.vpc_id
  subnets_list   = module.aws_network.subnets_list
  security_group = module.aws_security.security_group
  ec2_profile    = module.aws_security.ec2_profile
  app_lb         = module.aws_app_layer.app_lb

  inst_params = var.inst_params
  tags        = var.tags
}
# Bastion server for admin tasks
module "aws_admin" {
  source         = "./modules/aws_admin"
  subnets_list   = module.aws_network.subnets_list
  security_group = module.aws_security.security_group

  inst_params = var.inst_params
  tags        = var.tags
}