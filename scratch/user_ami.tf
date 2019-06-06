variable "region" {
  description = "AWS region to host your network"
  default     = "us-west-1"
}

variable "amis" {
  description = "Base AMI to launch the instances with"

  default = {
    us-west-1 = "ami-063aa838bd7631e0b"

    # us-west-1 = "ami-0ec6517f6edbf8044"
    us-east-1 = "ami-0ac019f4fcb7cb7e6"
  }
}

locals {
  instance = "${lookup(var.amis, var.region)}"
}

output "9_amis" {
  value = "${var.amis}"
}

output "instance" {
  value = "${local.instance}"
}

provider "aws" {
  region = "${var.region}"
}

data "aws_ami" "centos" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "name"
    values = ["CentOS Linux 7*"]
  }
}

output "my_ami" {
  value = "${data.aws_ami.centos.image_id}"
}
