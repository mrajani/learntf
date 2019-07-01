variable "profile" {
  default = "sandbox"
}
variable "region" {
  default = "us-west-2"
}
variable "name" {
  description = "Name of the VPC"
  default     = "Area99"
}

variable "vpc_cidr" {
  default = "10.10.0.0/16"
}

variable "subnet_count" {
  description = "Number of Subnets"
  default     = "3"
}

variable "use_az_count" {
  description = "Number of AZs to use"
  default     = "2"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default = {
    Name        = "Area99"
    Environment = "Env"
    AccountId   = "XYZ98760"
    RandomeCode = "YSTPLW"
  }
}

variable "key_pair_path" {
  default = "/Scratch/aws_key"
}

variable "enable_nat_gateway" {
  description = "Enable or Disable NAT gateway"
  default     = "true"
}

variable "dns_zone_name" {
  default     = "iono.local"
  description = "the internal dns name"
}