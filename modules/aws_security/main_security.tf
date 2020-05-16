# Security
# /////////////////////////////////////////////////////
# IAM role and Instance profile for EC2 to read from S3
resource "aws_iam_role" "ec2_read_s3_role" {
  name = "terraform_ec2_read_s3"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "s3_read_attach" {
  role       = aws_iam_role.ec2_read_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2_read_s3_profile" {
  name = "terraform_ec2_read_s3"
  role = aws_iam_role.ec2_read_s3_role.name
}
# /////////////////////////////////////////
# IAM role and Instance profile for Jenkins
resource "aws_iam_role" "ec2_jenkins_role" {
  name = "terraform_ec2_jenkins"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "jenkins_attach" {
  role       = aws_iam_role.ec2_jenkins_role.name
  for_each   = toset(var.iam_policies_arn_jenkins)
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "ec2_jenkins_profile" {
  name = "terraform_ec2_jenkins"
  role = aws_iam_role.ec2_jenkins_role.name
}

# Security Groups
# ////////////////////
# Security Group - ELB
resource "aws_security_group" "sg_load_balancer" {
  name   = "elb"
  vpc_id = var.vpc_id
  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Jenkins access
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }
  # outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "ELB"
    Tool        = var.tags["Tool"]
    Environment = var.tags["Environment"]
  }
}
# ////////////////////////////
# Security Group - for bastion
resource "aws_security_group" "sg_bastion" {
  name   = "bastion"
  vpc_id = var.vpc_id
  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }
  # outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "Bastion"
    Tool        = var.tags["Tool"]
    Environment = var.tags["Environment"]
  }
}
# //////////////////////////////////////////////////////
# Security Group - Launch Template for application layer
resource "aws_security_group" "sg_launch_template" {
  name   = "application"
  vpc_id = var.vpc_id
  # SSH access
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_bastion.id]
  }
  # HTTPS access
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_load_balancer.id]
  }
  # HTTP access
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_load_balancer.id]
  }
  # outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "Application"
    Tool        = var.tags["Tool"]
    Environment = var.tags["Environment"]
  }
}
# ///////////////////////////////////////////////
# Security Group - for Jenkins, application layer
resource "aws_security_group" "sg_jenkins" {
  name   = "jenkins"
  vpc_id = var.vpc_id
  # SSH access
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_bastion.id]
  }
  # Jenkins access
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_load_balancer.id]
  }
  # outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "Jenkins"
    Tool        = var.tags["Tool"]
    Environment = var.tags["Environment"]
  }
}