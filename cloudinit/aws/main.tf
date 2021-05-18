data "aws_vpc" "selected" {
  default = true
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud_config.yml",
      {
        userlogin = var.userlogin
    })
  }
  part {
    content_type = "text/x-shellscript"
    content      = <<-EOL
      #!/bin/bash
      echo Hello World | tee /tmp/greetings
      id | tee /tmp/mytrueid
    EOL
  }
}

resource "aws_instance" "ec21" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  user_data     = data.cloudinit_config.config.rendered
  key_name      = "backuprole"
  tags = {
    Name = "vm-1"
  }
}

resource "aws_key_pair" "keys" {
  key_name   = "backuprole"
  public_key = file(var.ssh_key)
}

variable "region" {
  default = "us-east-1"
}

provider "aws" {
  region = var.region
}

output "my_vpc" {
  value = data.aws_vpc.selected.id
}

output "ami" {
  value = data.aws_ami.ubuntu.id
}

output "userdata" {
  value = data.cloudinit_config.config.rendered
}