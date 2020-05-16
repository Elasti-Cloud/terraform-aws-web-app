# Jenkins server and LB connection
# ///////////////
# Jenkins traffic
resource "aws_lb_target_group" "lb_jenkins_target" {
  name        = "jenkins-target"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "jenkins_listner" {
  load_balancer_arn = var.app_lb.arn
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
# ////////////////////////////////////
# Jenkins stand-alone server for CI/CD
resource "aws_instance" "jenkins_server" {
  ami                    = var.inst_params["ami"]["jenkins"]
  instance_type          = var.inst_params["type"]["jenkins"]
  key_name               = var.inst_params["key_name"]["jenkins"]
  subnet_id              = var.subnets_list["private"][1].id
  vpc_security_group_ids = [var.security_group["jenkins"].id]
  # User Data for the Ubuntu OS
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