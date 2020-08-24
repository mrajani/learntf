resource "aws_kms_key" "this" {
  description             = "KMS key for S3 encryption"
  deletion_window_in_days = 10
  is_enabled              = true
}

resource "aws_kms_alias" "this" {
  name          = "alias/s3-encrypt-key"
  target_key_id = aws_kms_key.this.key_id
}


resource "aws_kms_ciphertext" "this" {
  key_id    = aws_kms_key.this.key_id
  plaintext = "hello world"
}

output "b1_key_arn" {
  value = aws_kms_key.this.arn
}

output "b1_key_id" {
  value = aws_kms_key.this.key_id
}

output "b2_targetkey_arn" {
  value = aws_kms_alias.this.target_key_arn
}

output "b2_keyalias_arn" {
  value = aws_kms_alias.this.arn
}

output "b3_ciphertext_blob" {
  value = aws_kms_ciphertext.this.ciphertext_blob
}
