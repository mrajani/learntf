provider "aws" {
  region = "us-east-1"
}

#---- This module will create a key pair ----#
module "ssh_key_pair" {
  source          = "./modules/ssh_key_pair"
  key_name        = var.key_name
  key_name_prefix = var.key_name_prefix
  public_key      = var.public_key
  generate        = var.gen_key_pair
}
