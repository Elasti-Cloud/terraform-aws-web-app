output "ec2_profile" {
  description = "Dict of Instance Profiles"
  value = {
    s3read  = aws_iam_instance_profile.ec2_read_s3_profile
    jenkins = aws_iam_instance_profile.ec2_jenkins_profile
  }
}

output "security_group" {
  description = "Dict of Security Groups"
  value = {
    load_balancer = aws_security_group.sg_load_balancer
    bastion       = aws_security_group.sg_bastion
    application   = aws_security_group.sg_launch_template
    jenkins       = aws_security_group.sg_jenkins
  }
}