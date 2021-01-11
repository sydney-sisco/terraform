resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"
  
  tags = {
    Name = "private routes"
  }
}

resource "aws_route" "priv-nat" {
  route_table_id            = "${aws_route_table.private.id}"
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.ngw.id}"
  depends_on                = ["aws_route_table.private"]
}

resource "aws_route_table_association" "private" {
  count = 3
  subnet_id      = "${aws_subnet.private.*.id[count.index]}"
  route_table_id = "${aws_route_table.private.id}"
}