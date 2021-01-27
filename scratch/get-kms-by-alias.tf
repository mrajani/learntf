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

variable "key_alias" {
  default = "vault-auto-unseal-88ba60e5"
}

data "aws_kms_key" "current" {
  key_id = "alias/${var.key_alias}"
}

output vpc_id {
  value = data.aws_kms_key.current
}

