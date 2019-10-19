output "key_name" {
  description = "The key pair name."
  value       = element(concat(aws_key_pair.ssh_key.*.key_name, list("")), 0)
}

output "key_fingerprint" {
  description = "The MD5 fingerprint"
  value       = element(concat(aws_key_pair.ssh_key.*.fingerprint, list("")), 0)
}

