/* Setup our aws provider */
provider "aws" {
  region = "${var.region}"
  shared_credentials_file = "/home/laltopi/.aws/credentials"
}

/* Define our vpc */
resource "aws_vpc" "vpc_main" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "${var.prefix}-vpc-main"
  }
}
