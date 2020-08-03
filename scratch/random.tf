## Create a random bucket id string
resource "random_string" "pw" {
  length  = 8
  upper   = false
  special = false
  number  = false
}

resource "random_id" "tf_bucket_id" {
  byte_length = 4
}

output "bucket_id_append" {
  value = "${random_string.pw.result}-${random_id.tf_bucket_id.dec}"
}

## change the random_pet always when apply
resource "null_resource" "change" {
  triggers = {
    time = "${timestamp()}"
  }
}

resource "random_pet" "my_pet" {
  prefix    = "i"
  separator = "-"
  keepers = {
    change = null_resource.change.id
  }
}

output "change" {
  value = "${null_resource.change.id}"
}

output "petname" {
  value = "${random_pet.my_pet.id}"
}

### Time Resource
resource "time_static" "current" {}
output "current_time" {
  value = time_static.current.rfc3339
} 
