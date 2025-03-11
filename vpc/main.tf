resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block_vpc
  tags = {
    Name = "3tier-VPC"
  }
}

#|||||||SUBREDES PUBLICAS PARA CAPA DE FRONTEND|||||||||||||
resource "aws_subnet" "public-subnet" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.cidr_block_public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet ${count.index + 1}"
    Owner = "Bruno"
    Env = "dev"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "IGW 1"
    Owner = "Bruno"
  }
}

resource "aws_route_table" "rt_publics_subnets" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "RT publics subnets"
    Owner = "Bruno"
  }
}

resource "aws_route_table_association" "rt_publics_subnets_association" {
  count = length(var.availability_zones)
  route_table_id = aws_route_table.rt_publics_subnets.id
  subnet_id = aws_subnet.public-subnet[count.index].id
}

#|||||||||SUBREDES PRIVADAS PARA CAPA DE BACKEND||||||||||||||
resource "aws_subnet" "private-subnet" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.cidr_block_private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "Private subnet ${count.index + 1}"
    Owner = "Bruno"
  }
}

resource "aws_eip" "eips" {
  count = length(var.availability_zones)
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateways" {
  count = length(var.availability_zones)
  subnet_id = aws_subnet.public-subnet[count.index].id
  allocation_id = aws_eip.eips[count.index].id
  tags = {
    Name = "NAT Gateway para ${var.availability_zones[count.index]}"
    Owner = "Bruno"
  }
}

resource "aws_route_table" "rt_private_subnet" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateways[count.index].id
  }

  tags = {
    Name = "RT private subnet 1a"
    Owner = "Bruno"
  }
}

resource "aws_route_table_association" "rt_private_subnets_associations" {
  count = length(var.availability_zones)
  route_table_id = aws_route_table.rt_private_subnet[count.index].id
  subnet_id = aws_subnet.private-subnet[count.index].id
}