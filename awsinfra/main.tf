/* Setup our AWS provider */
provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${file("${var.creds_path}")}"
}

data "aws_availability_zones" "available" {}

/* Define VPC */
module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  azs                  = "${slice(data.aws_availability_zones.available.names,0,var.subnet_count)}"

  tags {
    Name        = "${var.name}"
    Environment = "${var.env}"
    AccountId   = "${var.account_id}"
    RandomeCode = "${var.random_code}"
  }
}
