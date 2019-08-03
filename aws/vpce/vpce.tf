provider "aws" {
  region  = var.region
  version = "~> 2.20"
}

// Create Route Tables for VPC endpoint
resource "aws_route_table" "vpce" {
  vpc_id = data.terraform_remote_state.current.outputs.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(var.tags, map("Name", format("%s-rt-public", var.tags["Name"])))
}

resource "aws_vpc_endpoint_route_table_association" "example" {
  route_table_id  = "${aws_route_table.vpce.id}"
  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
}

// Create VPC endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id          = data.terraform_remote_state.current.outputs.vpc_id
  service_name    = var.s3_service_name
  route_table_ids = [var.vpce_routetbl_id]
  tags            = merge(var.tags, map("Name", format("%s-vpce-s3", var.tags["Name"])))
}

resource "aws_vpc_endpoint_route_table_association" "example" {
  route_table_id  = "${aws_route_table.vpce.id}"
  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
}
