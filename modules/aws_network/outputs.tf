output "vpc_id" {
  description = "VPC"
  value       = aws_vpc.vpc.id
}

output "subnets_list" {

  value = {
    public  = [for subnet in aws_subnet.public : subnet]
    private = [for subnet in aws_subnet.private : subnet]
  }
}
