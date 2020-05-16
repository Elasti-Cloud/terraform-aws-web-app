output "app_lb" {
  description = "Reference to ELB"
  value       = aws_lb.app_lb
}

output "lb_dns" {
  description = "DNS name of the load balancer."
  value       = aws_lb.app_lb.dns_name
}
