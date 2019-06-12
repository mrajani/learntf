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

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr, 8, count.index + 1 + length(var.azs))}"
  availability_zone = "${element(var.azs, count.index)}"
  count             = "${length(var.azs)}"
  tags              = "${merge(var.tags, var.private_subnet_tags, map("Name", format("%s-private-%s", var.tags["Name"], element(var.azs, count.index))))}"
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr, 8, count.index + 1)}"
  availability_zone       = "${element(var.azs, count.index)}"
  count                   = "${length(var.azs)}"
  tags                    = "${merge(var.tags, var.public_subnet_tags, map("Name", format("%s-public-%s", var.tags["Name"], element(var.azs, count.index))))}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"
}
