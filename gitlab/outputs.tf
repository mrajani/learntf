output "access_key_id" {
  value = aws_iam_access_key.secret.id
}

output "secret_access_key" {
  value = aws_iam_access_key.secret.encrypted_secret
}

output "s3backup_bucket" {
  value = aws_s3_bucket.gitlab.id
}