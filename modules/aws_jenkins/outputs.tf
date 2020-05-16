output "jenkins_ip" {
  description = "Jenkins server: privet IPv4"
  value       = aws_instance.jenkins_server.private_ip
}
