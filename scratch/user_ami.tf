variable "region" {
  description = "AWS region to host your network"
  default     = "us-west-2"
}

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

output "9_amis" {
  value = "${var.amis}"
}

output "instance" {
  value = "${local.instance}"
}

provider "aws" {
  region = "${var.region}"
}

data "aws_ami" "amazon" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "amzn2-ami-hvm-2.0.*-x86_64-gp2"

  filter {
    name   = "owner-id"
    values = ["137112412989"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
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

output "amazon_ami" {
  value = "${data.aws_ami.amazon.image_id}"
}

output "ubuntu_ami" {
  value = "${data.aws_ami.ubuntu.image_id}"
}

output "centos_ami" {
  value = "${data.aws_ami.centos.image_id}"
}
