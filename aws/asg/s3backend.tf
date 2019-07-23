terraform {
  backend "s3" {
    bucket         = "remote-tfstate-w4ebyiqzmy1y"
    key            = "sandbox/asg/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-remotelock"
  }
}
