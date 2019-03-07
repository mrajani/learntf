resource "aws_key_pair" "deployer" {
  key_name = "tf-deployer-key"
  public_key = "${file("/home/laltopi/.ssh/aws_tfadmin_id.pub")}"
}