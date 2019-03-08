resource "aws_key_pair" "deployer" {
  key_name = "${var.prefix}-key"
  public_key = "${file("/home/laltopi/.ssh/aws_tfadmin_id.pub")}"
}