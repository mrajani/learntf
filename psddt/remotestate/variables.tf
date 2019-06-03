variable "region" {
  description = "AWS region to host your network"
  default     = "us-west-1"
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  default     = "10.1.0.0/24"

  # 10.10.0.0/24
}

variable "private_subnet_cidr" {
  description = "CIDR for private subnet"
  default     = "10.1.1.0/24"

  # 10.10.1.0/24
}

/* Ubuntu 18.04 amis by region */
variable "amis" {
  description = "Base AMI to launch the instances with"

  default = {
    us-west-1 = "ami-063aa838bd7631e0b"

    # us-west-1 = "ami-0ec6517f6edbf8044"
    us-east-1 = "ami-0ac019f4fcb7cb7e6"
  }
}

variable "instance_type" {
  default = "t2.micro"
}

variable "login" {
  description = "default login ex. ubuntu or ec2-user or bitnami"
  default     = "ubuntu"
}

variable "prefix" {
  description = "setup a prefix for all your deployed resources using terraform"
  default     = "s3backend"
}

variable "key_pair_path" {
  description = "path to key pair"
  default     = "/home/vagrant/.ssh/aws_tfadmin_id"
}

variable "creds_path" {
  description = "path to credentials pair"
  default     = "/home/vagrant/.aws/credentials"
}

data "aws_availability_zones" "azs" {}

### PreRequisites for s3 Backend tfstatelock

variable "aws_dynamodb_table" {
  default = "ddt-tfstatelock"
}

variable "user_home_path" {
  default = ".."

  ##### creates an .aws dir in current dir ######
}
