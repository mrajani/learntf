
output "secret_id_key" {
  value     = aws_iam_access_key.secret
  sensitive = true
}

output "s3backup_bucket" {
  value = aws_s3_bucket.gitlab.id
}