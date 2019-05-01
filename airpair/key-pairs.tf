resource "aws_key_pair" "deployer" {
  key_name = "${var.prefix}-key"
  public_key = "${file("${var.key_pair_path}.pub")}"
}
