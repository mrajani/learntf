resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  instance_tenancy     = "${var.instance_tenancy}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  tags                 = "${merge(var.tags, map("ExtraTag", format("%s", var.prefix)))}"
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
  tags   = "${merge(var.tags, map("Name", format("%s-igw", var.tags["Name"])))}"
}

##### Setup Public Subnet, Route Table, Association with igw- 
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr, 8, count.index + 1)}"
  availability_zone       = "${element(var.azs, count.index)}"
  count                   = "${length(var.azs)}"
  tags                    = "${merge(var.tags, var.public_subnet_tags, map("Name", format("%s-rt-public-%s", var.tags["Name"], element(var.azs, count.index))))}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"
}

resource "aws_route_table" "public" {
  vpc_id           = "${aws_vpc.main.id}"
  propagating_vgws = ["${var.public_propagating_vgws}"]
  tags             = "${merge(var.tags, map("Name", format("%s-rt-public-%s", var.tags["Name"], element(var.azs, count.index))))}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

##### Setup Private Subnet, Route Table, Association with nat-gw- 

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr, 8, count.index + 1 + length(var.azs))}"
  availability_zone = "${element(var.azs, count.index)}"
  count             = "${length(var.azs)}"
  tags              = "${merge(var.tags, var.private_subnet_tags, map("Name", format("%s-private-%s", var.tags["Name"], element(var.azs, count.index))))}"
}

resource "aws_eip" "nateip" {
  vpc   = true
  count = "${length(var.azs) * lookup(map(var.enable_nat_gateway, 1), "true", 0)}"
  tags  = "${merge(var.tags, var.private_subnet_tags, map("Name", format("%s-eip-%s", var.tags["Name"], element(var.azs, count.index))))}"
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = "${element(aws_eip.nateip.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.private.*.id, count.index)}"
  count         = "${length(var.azs) * lookup(map(var.enable_nat_gateway, 1), "true", 0)}"
  depends_on    = ["aws_internet_gateway.main"]
}

resource "aws_route_table" "private" {
  vpc_id           = "${aws_vpc.main.id}"
  propagating_vgws = ["${var.private_propagating_vgws}"]
  tags             = "${merge(var.tags, map("Name", format("%s-rt-private-%s", var.tags["Name"], element(var.azs, count.index))))}"

  route {
    cidr_block = "0.0.0.0/0"

    nat_gateway_id = "${element(aws_nat_gateway.natgw.*.id, count.index)}"
  }
}

resource "aws_route_table_association" "nat" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

// Define Security groups
resource "aws_security_group" "default" {
  name        = "${var.prefix}-sg-default"
  description = "Default security group that allows inbound and outbound traffic from all instances in the VPC"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${merge(var.tags, var.public_subnet_tags, map("Name", format("%s-sg-default-%s", var.tags["Name"], element(var.azs, count.index))))}"

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
}

// Security Groups 
resource "aws_security_group" "nat" {
  name        = "${var.prefix}-sg-nat"
  description = "Security group for nat instances that allows SSH and VPN traffic from internet. Also allows outbound HTTP[S]"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${merge(var.tags, var.public_subnet_tags, map("Name", format("%s-sg-nat-%s", var.tags["Name"], element(var.azs, count.index))))}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "public" {
  name        = "${var.prefix}-sg-web"
  description = "Security group for Public Subnet that allows traffic from internet"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${merge(var.tags, var.public_subnet_tags, map("Name", format("%s-sg-public-%s", var.tags["Name"], element(var.azs, count.index))))}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
