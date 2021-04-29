terraform {
  required_version = "~> 0.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.37"
    }
    random   = "~> 2.3"
    template = "~> 2.2"
    local    = "~> 1.4"
  }
}

provider "aws" {
  region = var.region
}
