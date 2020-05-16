# Bastion server for admin tasks
resource "aws_instance" "bastion" {
  ami                    = var.inst_params["ami"]["bastion"]
  instance_type          = var.inst_params["type"]["bastion"]
  key_name               = var.inst_params["key_name"]["bastion"]
  subnet_id              = var.subnets_list["public"][0].id
  vpc_security_group_ids = [var.security_group["bastion"].id]
  tags = {
    Name        = "bastion"
    Tool        = var.tags["Tool"]
    Environment = var.tags["Environment"]
  }
}