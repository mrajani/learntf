/* NAT/VPN server */
resource "aws_instance" "nat" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "${var.instance_type}"
  subnet_id = "${aws_subnet.public.id}"
  security_groups = ["${aws_security_group.default.id}", "${aws_security_group.nat.id}"]
  key_name = "${aws_key_pair.deployer.key_name}"
  source_dest_check = false
  tags = {
    Name = "${var.prefix}-nat-inst"
  }
  connection {
    user = "${var.login}"
    private_key = "${file("${var.key_pair_path}")}"
  }
  provisioner "remote-exec" {
    inline = [
      "curl -sSL https://raw.githubusercontent.com/mrajani/learnvagrant/master/shared/gitinstall.sh | sudo bash",
      "curl -sSL https://raw.githubusercontent.com/mrajani/learndocker/master/install_docker.sh | sudo bash"
    ]
  }
}
