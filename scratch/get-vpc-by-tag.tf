terraform {
  required_version = "~> 0.13"
  required_providers {
    random   = "~> 2.3"
    template = "~> 2.2"
    local    = "~> 1.4"
    tls      = "~> 2.2"
    aws      = "~> 3.0"
  }
}

provider "aws" {
  region                  = "us-east-1"
  profile                 = "sandbox"
  shared_credentials_file = "$HOME/.aws/credentials"
}

### One of the tag is identity and value is consul-vault 
variable "tag_key" {
  default = "identity"
}

variable "tag_value" {
  default = "consul-vault"
}

data "aws_vpc" "current" {
  default = false
  state   = "available"
  filter {
    name   = "tag:${var.tag_key}"
    values = [var.tag_value]
  }
}

output vpc_id {
  value = data.aws_vpc.current.id
}

