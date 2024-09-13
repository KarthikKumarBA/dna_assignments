resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${var.application_name}-VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.application_name}-IGW"
  }
}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block =  var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "${var.application_name}-ROUTE"
  }
}
resource "aws_subnet" "subnet_a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.pub_sub_cidr
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"

  tags = {
    Name = "${var.application_name}-Pub-Sub"
  }
}
resource "aws_subnet" "subnet_b" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.pub_sub_cidr1
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1c"

  tags = {
    Name = "${var.application_name}-Pub-Sub1"
  }
}


resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_route_table_association" "sub_ass" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.route.id
}
resource "aws_route_table_association" "sub_ass1" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.route.id
}