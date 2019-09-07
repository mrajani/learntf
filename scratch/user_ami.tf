variable "region" {
  description = "AWS region to host your network"
  default     = "us-west-2"
}

variable "profile" {}

variable "amis" {
  description = "Base AMI to launch the instances with"
  default = {
    us-west-1 = "ami-063aa838bd7631e0b"
    us-west-2 = "ami-0cb72367e98845d43"
    us-east-1 = "ami-0ac019f4fcb7cb7e6"
  }
}

locals {
  instance = "${lookup(var.amis, var.region)}"
}

provider "aws" {
  region = var.region
  profile = var.profile
}

variable "filters" {
  type = list(map(string))
}

data "aws_ami" "amazon" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "amzn2-ami-hvm-2.0.*-x86_64-gp2"

  filter {
    name   = "owner-id"
    values = ["137112412989"]
  }

  dynamic "filter" {
    for_each = var.filters
    content {
      name   = filter.value["name"]
      values = [filter.value["value"]]
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  name_regex  = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-2019*"

  filter {
    name   = "owner-id"
    values = ["099720109477"]
  }

  dynamic "filter" {
    for_each = var.filters
    content {
      name   = filter.value["name"]
      values = [filter.value["value"]]
    }
  }
}

data "aws_ami" "centos" {
  most_recent = true
  owners      = ["aws-marketplace"]
  name_regex  = "CentOS Linux 7*"

  filter {
    name   = "owner-id"
    values = ["679593333241"]
  }

  dynamic "filter" {
    for_each = var.filters
    content {
      name   = filter.value["name"]
      values = [filter.value["value"]]
    }
  }
}

output "amazon_ami" {
  value = "${data.aws_ami.amazon}"
}

output "ubuntu_ami" {
  value = "${data.aws_ami.ubuntu}"
}

output "centos_ami" {
  value = "${data.aws_ami.centos}"
}

output "amis" {
  value = "${var.amis}"
}

output "instance" {
  value = "${local.instance}"
}

