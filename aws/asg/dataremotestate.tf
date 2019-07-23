data "terraform_remote_state" "current" {
  backend = "s3"
  config = {
    bucket         = "remote-tfstate-pqc1jhomr7lw"
    key            = "sandbox/vpc/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-remotelock"
  }
}

output "myvpc" {
  value = data.terraform_remote_state.current.outputs.vpc_id
}


