provider "aws" {
  region = "us-east-1"
}

locals {
  key_file = "${var.key_name  == null ? var.key_file : var.key_name}"
}

#-------- Gen Key Pair --------#
resource "tls_private_key" "ssh" {
  count       = var.generate ? 1 : 0
  algorithm   = "RSA"
  ecdsa_curve = "2048"
}

resource "local_file" "private_pem" {
  count           = var.generate ? 1 : 0
  content         = tls_private_key.ssh[count.index].private_key_pem
  filename        = pathexpand("~/.ssh/${local.key_file}.pem")
  file_permission = "0600"
}

resource "local_file" "public_openssh" {
  count           = var.generate ? 1 : 0
  content         = tls_private_key.ssh[count.index].public_key_openssh
  filename        = pathexpand("~/.ssh/${local.key_file}.pub")
  file_permission = "0644"
}

resource "aws_key_pair" "ssh_key" {
  count = 1
  key_name = local.key_file
  key_name_prefix = var.key_name_prefix

  public_key = "${var.public_key == null ?
    tls_private_key.ssh[count.index].public_key_openssh :
  file("${var.public_key}.pub")}"
}
