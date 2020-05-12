# Bastion server for admin tasks
resource "aws_instance" "bastion" {
  ami                    = var.ami["bastion"]
  instance_type          = var.instance_type["bastion"]
  key_name               = var.key_name["bastion"]
  subnet_id              = var.subnets_list["public02"].id
  vpc_security_group_ids = [var.security_group["bastion"].id]
  tags = {
    Name        = "bastion"
    Tool        = var.tags["Tool"]
    Environment = var.tags["Environment"]
  }
}