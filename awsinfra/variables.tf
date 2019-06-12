variable "region" {
  description = "Oregon is default region"
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "Network block for the VPC - create one for each env"
  default     = "10.41.0.0/16"
}

variable "name" {
  description = "Name of the VPC"
  default     = ""
}

variable "prefix" {
  description = "Prefix value for unique tagging"
  default     = "iono"
}

variable "env" {
  description = "Environment - ex prod, dev, stage"
  default     = "dev"
}

variable "account_id" {
  description = "Account Id of the BU for billing purposes"
  default     = ""
}

variable "random_code" {
  description = "random code for tagging, might use random provider in terraform"
  default     = ""
}

variable "creds_path" {
  description = "full path to credentials"
  default     = "../../credentials"
}

variable "subnet_count" {
  description = "Number of Subnets to create, use tfvars for each env"
  default     = ""
}
