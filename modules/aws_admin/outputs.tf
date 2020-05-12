output "bastion_public_ip" {
  description = "Bastion Server: public IPv4"
  value       = aws_instance.bastion.public_ip
}