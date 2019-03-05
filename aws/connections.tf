variable "region" {
  default = "us-west-2"
}

provider "aws" {
  region = "${var.region}"
  shared_credentials_file = "/home/laltopi/.aws/credentials"
}
