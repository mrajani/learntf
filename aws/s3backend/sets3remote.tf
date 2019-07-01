#-------- Variables and Locals --------#
resource "random_string" "bucket_prefix" {
  length  = 12
  upper   = false
  special = false
  number  = true
}

locals {
  backend_bucket = "remote-tfstate-${random_string.bucket_prefix.result}"
}

variable "region" {
  default = "us-east-1"
}
variable "creds_path" {
  description = "Path to shared_credentials_file"
  default     = "/Scratch/credentials"
}
variable "profile" {
  description = "Select a Profile in creds file"
  default     = "default"
}

variable "aws_dynamodb_table" {
  default = "tfstate-remotelock"
}


#-------- Providers --------
provider "aws" {
  region                  = var.region
  profile                 = var.profile
  shared_credentials_file = var.creds_path
}

#-------- Resources --------

resource "aws_dynamodb_table" "terraform_statelock" {
  name           = "${var.aws_dynamodb_table}"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = "TF Locktable"
    Purpose = "Remote State Backend"
  }
}

resource "aws_s3_bucket" "backend" {
  bucket        = "${local.backend_bucket}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = {
    Name    = "remote-tfstate-${random_string.bucket_prefix.result}"
    Purpose = "S3 Bucket for remote state"
  }
}

resource "local_file" "s3_profile" {
  content = <<EOF
terraform {
  backend "s3" {
    bucket         = "${local.backend_bucket}"
    key            = "${var.profile}/terraform.state"
    region         = "${var.region}"
    dynamodb_table = "${var.aws_dynamodb_table}"
  }
}
EOF
  filename = "../backend.tf.ignore"
}