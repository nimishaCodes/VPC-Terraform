# main.tf

provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Public Subnet 1 (in AZ1)
resource "aws_subnet" "public_subnet_az1" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-az1"
  }
}

# Public Subnet 2 (in AZ2)
resource "aws_subnet" "public_subnet_az2" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-az2"
  }
}

# Private Subnet 1 (in AZ1)
resource "aws_subnet" "private_subnet_az1" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet-az1"
  }
}

# Private Subnet 2 (in AZ2)
resource "aws_subnet" "private_subnet_az2" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-subnet-az2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

# Public Route Table Association for Subnet 1
resource "aws_route_table_association" "public_rt_assoc_az1" {
  subnet_id = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Public Route Table Association for Subnet 2
resource "aws_route_table_association" "public_rt_assoc_az2" {
  subnet_id = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

# NAT Gateway (in Public Subnet 1)
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_az1.id
}

# Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "private-route-table"
  }
}

# Private Route Table Association for Subnet 1
resource "aws_route_table_association" "private_rt_assoc_az1" {
  subnet_id = aws_subnet.private_subnet_az1.id
  route_table_id = aws_route_table.private_route_table.id
}

# Private Route Table Association for Subnet 2
resource "aws_route_table_association" "private_rt_assoc_az2" {
  subnet_id = aws_subnet.private_subnet_az2.id
  route_table_id = aws_route_table.private_route_table.id
}
