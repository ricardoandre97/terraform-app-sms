resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  tags                 = {
    Name    = "${var.project}-vpc"
    Project = "${var.project}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags   = {
    Name    = "${var.project}-internet_gateway"
    Project = "${var.project}"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet1_cidr
  availability_zone = "${var.region}a"

  tags = {
    Name    = "${var.project}-subnet1"
    Project = "${var.project}"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet2_cidr
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.project}-subnet2"
    Project = "${var.project}"
  }
}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.project}-route_table"
    Project = "${var.project}"
  }

}

resource "aws_route_table_association" "subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route.id
}

resource "aws_route_table_association" "subnet2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.route.id
}