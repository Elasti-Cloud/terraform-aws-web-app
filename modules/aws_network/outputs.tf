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
/*
output "subnets_list" {
  description = "List of subnets: 2 public and 2 private"
  value = {
    public01  = aws_subnet.public01
    public02  = aws_subnet.public02
    private01 = aws_subnet.private01
    private02 = aws_subnet.private02
  }
}
*/
