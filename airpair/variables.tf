# variable "access_key" {
#   description = "AWS access key"
# }
# Use Credentials Files
# variable "secret_key" {
#   description = "AWS secret access key"
# }

variable "region"     {
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

/* Ubuntu 14.04 amis by region */
variable "amis" {
  description = "Base AMI to launch the instances with"
  default = {
    us-west-1 = "ami-063aa838bd7631e0b"
    # us-west-1 = "ami-0ec6517f6edbf8044"
    us-east-1 = "ami-0ac019f4fcb7cb7e6"
  }
}

variable "login" {
  description = "User login based on AMI selected"
  default = "ec2-user"
}