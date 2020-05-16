/*output "bastion_public_ip" {
  description = "Bastion Server: public IPv4"
  value       = module.aws_admin.bastion_public_ip
}

output "jenkins_ip" {
  description = "Jenkins server: privet IPv4"
  value       = module.aws_app_layer.jenkins_ip
}

output "lb_dns" {
  description = "DNS name of the load balancer."
  value       = "http://${module.aws_app_layer.lb_dns}"
}

output "lb_dns_jenkins" {
  description = "DNS name of the load balancer for Jenkins."
  value       = "http://${module.aws_app_layer.lb_dns}:8080"
}
*/
output "subnets" {
  value = module.aws_network.subnets_list
}