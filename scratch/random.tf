resource "random_string" "pw" {
  length  = 4
  upper   = false
  special = false
  number  = false
}

resource "random_id" "tf_bucket_id" {
  byte_length = 2
  prefix      = "-"
}

output "1_string" {
  sensitive = false
  value     = "${random_string.pw.result}"
}

output "2_string" {
  value = "${random_id.tf_bucket_id.dec}"
}

output "3_string" {
  value = "${random_string.pw.result}${random_id.tf_bucket_id.dec}"
}
