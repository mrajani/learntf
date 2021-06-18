
terraform {
  required_version = ">= 0.12"
  required_providers {
    random   = "~> 2.2"
    template = "~> 2.1"
    local    = "~> 1.3"
    aws      = "~> 2.24"
  }
}
