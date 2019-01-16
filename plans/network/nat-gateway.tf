resource "aws_eip" "nat" {
  vpc      = true
  depends_on = ["aws_internet_gateway.igw"] #EIP may require IGW to exist prior to association.

  tags {
      Name = "NAT-EIP"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.*.id[0]}"

  tags = {
    Name = "NAT-main"
  }
}