resource "aws_vpc" "main" {
  cidr_block                       = var.vpc_cidr
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = true
  tags                             = var.tags

}
data "aws_availability_zones" "available" {
  state = "available"
}

// internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, map("Name", format("%s-igw", var.tags["Name"])))
}

// elastic ip address for nat gateways
resource "aws_eip" "nateip" {
  vpc   = true
  count = "${var.subnet_count * lookup(map(var.enable_nat_gateway, 1), "true", 0)}"
  tags  = merge(var.tags, map("Name", format("%s-nat-eip", var.tags["Name"])))
}



// Create three types of subnets, three each
resource "aws_subnet" "public" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = "${merge(var.tags, map("Name", format("%s-subnet-public-%s", var.tags["Name"], element(data.aws_availability_zones.available.names, count.index))))}"

}
resource "aws_subnet" "private" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 1 * length(data.aws_availability_zones.available.names))
  availability_zone = element(data.aws_availability_zones.available.names, count.index)


  tags = "${merge(var.tags, map("Name", format("%s-subnet-private-%s", var.tags["Name"], element(data.aws_availability_zones.available.names, count.index))))}"

}
resource "aws_subnet" "db" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 2 * length(data.aws_availability_zones.available.names))
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = "${merge(var.tags, map("Name", format("%s-subnet-db-%s", var.tags["Name"], element(data.aws_availability_zones.available.names, count.index))))}"

}

// Create Route Tables for Public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(var.tags, map("Name", format("%s-rt-public", var.tags["Name"])))
}

resource "aws_route_table_association" "public" {
  count          = var.subnet_count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}


// nat gateways
resource "aws_nat_gateway" "natgw" {
  count         = "${var.subnet_count * lookup(map(var.enable_nat_gateway, 1), "true", 0)}"
  allocation_id = element(aws_eip.nateip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = ["aws_internet_gateway.main"]
  tags          = merge(var.tags, map("Name", format("%s-ngw-%s", var.tags["Name"], element(data.aws_availability_zones.available.names, count.index))))
}


// route tables for private subnets
resource "aws_route_table" "internal" {
  count  = "${var.subnet_count * lookup(map(var.enable_nat_gateway, 1), "true", 0)}" # var.subnet_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw[count.index].id
  }
  tags = merge(var.tags, map("Name", format("%s-rt-internal", var.tags["Name"])))
}

resource "aws_route_table_association" "private" {
  count          = "${var.subnet_count * lookup(map(var.enable_nat_gateway, 1), "true", 0)}" # var.subnet_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.internal.*.id, count.index)
}
resource "aws_route_table_association" "db" {
  count          = "${var.subnet_count * lookup(map(var.enable_nat_gateway, 1), "true", 0)}" # var.subnet_count
  subnet_id      = element(aws_subnet.db.*.id, count.index)
  route_table_id = element(aws_route_table.internal.*.id, count.index)
}


// Security Groups
resource "aws_security_group" "public" {
  vpc_id      = aws_vpc.main.id
  name        = format("%s-sg-public", var.tags["Name"])
  description = "SG for External Access to VPC"
  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, map("Name", format("%s-sg-public", var.tags["Name"])))

}

resource "aws_security_group" "bastion" {
  vpc_id      = aws_vpc.main.id
  name        = format("%s-sg-bastion", var.tags["Name"])
  description = "SG for Access from Public Subnets"
  # SSH access from anywhere
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.public.id}"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, map("Name", format("%s-sg-bastion", var.tags["Name"])))

}
