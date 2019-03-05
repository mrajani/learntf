/* Setup our aws provider */
provider "aws" {
  # access_key  = "${var.access_key}"
  # secret_key  = "${var.secret_key}"
  region = "${var.region}"
  shared_credentials_file = "/home/laltopi/.aws/credentials"
}

/* Define our vpc */
resource "aws_vpc" "vpc_main" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "iono-tf-provision"
  }
}
