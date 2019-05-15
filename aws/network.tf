resource "aws_vpc" "vpcmain" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "TF-VPC01"
  }
}

resource "aws_subnet" "subnet" {
  cidr_block        = "${cidrsubnet(aws_vpc.vpcmain.cidr_block, 8, 0)}"
  vpc_id            = "${aws_vpc.vpcmain.id}"
  availability_zone = "us-west-2a"

  tags {
    Name = "TF-Subnet"
  }
}
