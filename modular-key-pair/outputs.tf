output "key_name" {
  description = "The key pair name."
  value       = module.ssh_key_pair.key_name
}

output "key_fingerprint" {
  description = "The MD5 fingerprint"
  value       = module.ssh_key_pair.key_fingerprint
}

