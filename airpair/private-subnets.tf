/* Private subnet */
resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.vpc_main.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc_main.cidr_block, 8, 1)}"
  availability_zone = "${data.aws_availability_zones.azs.names[0]}"
  map_public_ip_on_launch = false
  depends_on = ["aws_instance.nat"]
  tags {
    Name = "${var.prefix}-subnet-priv"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc_main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
  }
  tags {
    Name = "${var.prefix}-rt-priv"
  }
}

/* Associate the routing table to public subnet */
resource "aws_route_table_association" "private" {
  subnet_id = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"
}
