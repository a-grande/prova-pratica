resource "aws_vpc" "wordpress-vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "wordpress-vpc"
    }
}

# Subnet
resource "aws_subnet" "sub-private-a" {
    vpc_id = aws_vpc.wordpress-vpc.id
    cidr_block = var.private_subnet_cidr_a
    availability_zone = "eu-west-1a"
    tags = {
        Name = "PRI-A Subnet"
    }
}

resource "aws_subnet" "sub-public-a" {
    vpc_id = aws_vpc.wordpress-vpc.id
    cidr_block = var.public_subnet_cidr_a
    availability_zone = "eu-west-1a"

    tags = {
        Name = "PUB-A Subnet"
    }
}

resource "aws_subnet" "sub-private-b" {
    vpc_id = aws_vpc.wordpress-vpc.id
    cidr_block = var.private_subnet_cidr_b
    availability_zone = "eu-west-1b"
    tags = {
        Name = "PRI-B Subnet"
    }
}

resource "aws_subnet" "sub-public-b" {
    vpc_id = aws_vpc.wordpress-vpc.id
    cidr_block = var.public_subnet_cidr_b
    availability_zone = "eu-west-1b"
    tags = {
        Name = "PUB-B Subnet"
    }
}

# IG
resource "aws_internet_gateway" "ig-wordpress" {
    vpc_id = aws_vpc.wordpress-vpc.id
    tags = {
        Name = "IG-wordpress"
    }
}

# EIP
resource "aws_eip" "eip-nat" {
  depends_on = [ aws_internet_gateway.ig-wordpress ]
}

#NAT
resource "aws_nat_gateway" "nat-wordpress" {
    allocation_id = aws_eip.eip-nat.id
    subnet_id = aws_subnet.sub-public-a.id
}

# Routing Table
resource "aws_route_table" "prd-pub" {
    vpc_id = aws_vpc.wordpress-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig-wordpress.id
    }
    tags = {
        Name = "PUB-RT"
    }
}

resource "aws_route_table" "prd-pri" {
    vpc_id = aws_vpc.wordpress-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat-wordpress.id
    }
    tags = {
        Name = "PRI-RT"
    }
}

resource "aws_route_table_association" "pub-a" {
  subnet_id      = aws_subnet.sub-public-a.id
  route_table_id = aws_route_table.prd-pub.id
}

resource "aws_route_table_association" "pub-b" {
  subnet_id      = aws_subnet.sub-public-b.id
  route_table_id = aws_route_table.prd-pub.id
}

resource "aws_route_table_association" "pri-a" {
  subnet_id      = aws_subnet.sub-private-a.id
  route_table_id = aws_route_table.prd-pri.id
}

resource "aws_route_table_association" "pri-b" {
  subnet_id      = aws_subnet.sub-private-b.id
  route_table_id = aws_route_table.prd-pri.id
}
