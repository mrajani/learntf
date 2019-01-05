variable "do_token" {}
variable "pub_key" {}
variable "pvt_key" {}
variable "ssh_fingerprint" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

connection {
  user = "root"
  type = "ssh"
  private_key = "${file(var.pvt_key)}"
  timeout = "2m"
}

provisioner "remote-exec" {
  inline = [
    "export PATH=$PATH:/usr/bin",
    "sudo apt-get update && sudo apt-get install -y nginx"
  ]
}
