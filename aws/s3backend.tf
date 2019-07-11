terraform {
  backend "s3" {
    bucket         = "remote-tfstate-k1p51cmp0u4r"
    key            = "sandbox/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-remotelock"
  }
}
