resource "aws_s3_bucket" "main" {
  bucket = "${var.prefix}-s3-olpcaswi"
  acl    = "private"

  tags = {
    Name        = "${var.prefix}-s3"
    Environment = "Dev"
  }
}
