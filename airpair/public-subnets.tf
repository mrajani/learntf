/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.vpc_main.id}"
  tags {
    Name = "${var.prefix}-igw"
  }
}

/* Public subnet */
resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.vpc_main.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc_main.cidr_block, 8, 0)}"
  availability_zone = "us-west-1b"
  map_public_ip_on_launch = true
  depends_on = ["aws_internet_gateway.default"]
  tags {
    Name = "${var.prefix}-subnet-pub"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc_main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
  tags {
    Name = "${var.prefix}-rtpub-igw"
  }
}

/* Associate the routing table to public subnet */
resource "aws_route_table_association" "public" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}