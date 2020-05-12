# Data
data "aws_availability_zones" "azs" {}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags                 = var.tags
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = var.tags
}

# Public subnets
resource "aws_subnet" "public01" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.azs.names[0]
  cidr_block              = var.subnet_cidr["public01"]
  map_public_ip_on_launch = true

  tags = {
    Name        = "Public-01"
    Tool        = var.tags["Tool"]
    Environment = var.tags["Environment"]
  }
}

resource "aws_subnet" "public02" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.azs.names[1]
  cidr_block              = var.subnet_cidr["public02"]
  map_public_ip_on_launch = true

  tags = {
    Name        = "Public-02"
    Tool        = var.tags["Tool"]
    Environment = var.tags["Environment"]
  }
}

# Private subnet
resource "aws_subnet" "private01" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.azs.names[0]
  cidr_block              = var.subnet_cidr["private01"]
  map_public_ip_on_launch = false

  tags = {
    Name        = "Private-01"
    Tool        = var.tags["Tool"]
    Environment = var.tags["Environment"]
  }
}

resource "aws_subnet" "private02" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.azs.names[1]
  cidr_block              = var.subnet_cidr["private02"]
  map_public_ip_on_launch = false

  tags = {
    Name        = "Private-02"
    Tool        = var.tags["Tool"]
    Environment = var.tags["Environment"]
  }
}

# EIP for NAT
resource "aws_eip" "eip_nat" {
  vpc  = true
  tags = var.tags
}

# NAT Gateway
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id     = aws_subnet.public02.id
  depends_on    = [aws_internet_gateway.igw]
  tags          = var.tags
}

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

resource "aws_route_table_association" "rt_pub_subnet01" {
  subnet_id      = aws_subnet.public01.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "rt_pub_subnet02" {
  subnet_id      = aws_subnet.public02.id
  route_table_id = aws_route_table.rt_public.id
}

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

resource "aws_route_table_association" "rt_prv_subnet01" {
  subnet_id      = aws_subnet.private01.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table_association" "rt_prv_subnet02" {
  subnet_id      = aws_subnet.private02.id
  route_table_id = aws_route_table.rt_private.id
}