resource "aws_key_pair" "keys" {
  key_name   = "${var.name}-key"
  public_key = "${file("${var.key_pair_path}.pub")}"
}
