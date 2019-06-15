variable "prefix" {
  description = "Some random message to include in tags"
  default     = "iono"
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default     = ""
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
}

variable "azs" {
  description = "A list of Availability zones in the region"
  default     = []
}

variable "enable_dns_hostnames" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "enable_nat_gateway" {
  description = "Set to true to provision NAT Gateways for each of your private networks"
  default     = "true"
}

variable "map_public_ip_on_launch" {
  description = "should be false if you do not want to auto-assign public IP on launch"
  default     = true
}

variable "private_propagating_vgws" {
  description = "A list of VGWs the private route table should propagate."
  default     = []
}

variable "public_propagating_vgws" {
  description = "A list of VGWs the public route table should propagate."
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"

  default = {
    type = "public subnet"
  }
}

variable "private_subnet_tags" {
  description = "Additional tags for the public subnets"

  default = {
    type = "private subnet"
  }
}

variable "private_eip_tags" {
  description = "Additional tags for the Elastic IPs"

  default = {
    type = "eip for nat gateway"
  }
}
