output "lb_dns" {
  description = "DNS name of the load balancer."
  value       = aws_lb.app_lb.dns_name
}

output "jenkins_ip" {
  description = "Jenkins server: privet IPv4"
  value       = aws_instance.jenkins_server.private_ip
}
