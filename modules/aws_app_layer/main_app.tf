# Application Layer
# Launch Template
resource "aws_launch_template" "launch_template" {
  name = "application"
  iam_instance_profile {
    name = var.ec2_profile["s3read"].name
  }
  image_id               = var.ami["application"]
  instance_type          = var.instance_type["application"]
  key_name               = var.key_name["application"]
  vpc_security_group_ids = [var.security_group["application"].id]
  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }
  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install httpd -y
service httpd start
chkconfig httpd on
echo 'sudo aws s3 sync s3://${var.s3_bucket_source} /var/www/html' > /home/ec2-user/sync.sh
chmod +x /home/ec2-user/sync.sh
echo '* * * * * /home/ec2-user/sync.sh >/dev/null 2>&1' | crontab
cd /var/www/html
aws s3 sync s3://${var.s3_bucket_source} . 
EOF
  )
}

# AutoScaling Group
resource "aws_autoscaling_group" "asg_application" {
  name                = "application"
  max_size            = var.asg_param["max_size"]
  min_size            = var.asg_param["min_size"]
  desired_capacity    = var.asg_param["desired_capacity"]
  vpc_zone_identifier = [var.subnets_list["private01"].id, var.subnets_list["private02"].id]
  health_check_type   = "ELB"
  target_group_arns   = [aws_lb_target_group.lb_http_target.arn]

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

}

# Load Balancer
resource "aws_lb" "app_lb" {
  name               = "application-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group["load_balancer"].id]
  subnets            = [var.subnets_list["public01"].id, var.subnets_list["public02"].id]
  tags               = var.tags
}
# HTTP traffic
resource "aws_lb_target_group" "lb_http_target" {
  name        = "http-target"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "http_listner" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_http_target.arn
  }
}
# Jenkins traffic
resource "aws_lb_target_group" "lb_jenkins_target" {
  name        = "jenkins-target"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "jenkins_listner" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_jenkins_target.arn
  }
}

resource "aws_lb_target_group_attachment" "lb_to_jenkins" {
  target_group_arn = aws_lb_target_group.lb_jenkins_target.arn
  target_id        = aws_instance.jenkins_server.id
  port             = 8080
}

# Jenkins stand-alone server for CI/CD
resource "aws_instance" "jenkins_server" {
  ami                    = var.ami["jenkins"]
  instance_type          = var.instance_type["jenkins"]
  key_name               = var.key_name["jenkins"]
  subnet_id              = var.subnets_list["private02"].id
  vpc_security_group_ids = [var.security_group["jenkins"].id]
  user_data = base64encode(<<EOF
#!/bin/bash
apt-get update -y
apt install -y default-jdk
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update -y
apt-get install -y jenkins
systemctl start jenkins
systemctl enable jenkins
apt-get install -y tidy
EOF
  )
  iam_instance_profile = var.ec2_profile["jenkins"].name
  tags = {
    Name        = "jenkins"
    Tool        = var.tags["Tool"]
    Environment = var.tags["Environment"]
  }
}