# AWS Network
# ///
# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.network["vpc_cidr"]
  enable_dns_hostnames = true
  tags                 = var.tags
}
# ////////////////
# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = var.tags
}
# //////////////
# Public subnets
data "aws_availability_zones" "azs" {}

resource "aws_subnet" "public" {
  for_each                = var.network["public_cidr"]
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value
  availability_zone       = data.aws_availability_zones.azs.names[each.key]
  map_public_ip_on_launch = true

  tags = {
    Name        = "Public"
    Tool        = var.tags["Tool"]
    Environment = var.tags["Environment"]
  }
}
# ///////////////
# Private subnets
resource "aws_subnet" "private" {
  for_each                = var.network["private_cidr"]
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value
  availability_zone       = data.aws_availability_zones.azs.names[each.key]
  map_public_ip_on_launch = false

  tags = {
    Name        = "Private"
    Tool        = var.tags["Tool"]
    Environment = var.tags["Environment"]
  }
}
# ///////////
# EIP for NAT
resource "aws_eip" "eip_nat" {
  vpc  = true
  tags = var.tags
}
# ///////////
# NAT Gateway
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id     = aws_subnet.public[0].id
  tags          = var.tags
}
# ////////////////////
# Public routing table
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "Public"
    Tool        = var.tags["Tool"]
    Environment = var.tags["Environment"]
  }
}

resource "aws_route_table_association" "rt_pub_subnets" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.rt_public.id
}
# /////////////////////
# Private routing table
resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name        = "Private"
    Tool        = var.tags["Tool"]
    Environment = var.tags["Environment"]
  }
}

resource "aws_route_table_association" "rt_prv_subnets" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.rt_private.id
}