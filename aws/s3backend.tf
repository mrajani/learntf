terraform {
  backend "s3" {
    bucket         = "remote-tfstate-pqc1jhomr7lw"
    key            = "sandbox/vpc/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-remotelock"
  }
}
