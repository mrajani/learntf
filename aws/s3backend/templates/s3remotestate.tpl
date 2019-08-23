data "terraform_remote_state" "current" {
  backend = "s3"
  config = {
    bucket         = "${bucket}"
    key            = "${key}"
    region         = "${region}"
    dynamodb_table = "${dynamodb_table}"
  }
}

output "remotedata" {
  value = data.terraform_remote_state.current.outputs
}
