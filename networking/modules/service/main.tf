resource "aws_vpc" "primary" {
  cidr_block = var.cidr_block

  tags = {
    Name = "primary"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  count = length(data.aws_availability_zones.available.names)

  vpc_id     = aws_vpc.primary.id
  cidr_block = cidrsubnet(aws_vpc.primary.cidr_block, 8, count.index)

  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "private" {
  count = length(data.aws_availability_zones.available.names)

  vpc_id     = aws_vpc.primary.id
  cidr_block = cidrsubnet(aws_vpc.primary.cidr_block, 8, count.index + length(data.aws_availability_zones.available.names))

  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.primary.id

  tags = {
    Name = "igw-primary"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.primary.id

  tags = {
    Name = "public routes"
  }
}

resource "aws_route" "pub-igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  # depends_on                = ["aws_route_table.public"]
}

resource "aws_route_table_association" "public" {
  count = length(data.aws_availability_zones.available.names)

  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}
