#-------- VPC --------#
terraform {
  required_version = "~> 0.13.0"
  required_providers {
    random   = "~> 2.2"
    template = "~> 2.1"
    local    = "~> 1.4"
    aws      = "~> 2.32"
  }
}

provider "aws" {
  region                  = var.region
  profile                 = var.profile
  shared_credentials_file = "$HOME/.aws/credentials"
}

resource "aws_vpc" "main" {
  cidr_block                       = var.vpc_cidr
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = true
  tags                             = var.tags

}
data "aws_availability_zones" "available" {
  state = "available"
}

#-------- Pick Random AZs --------#
resource "random_shuffle" "azs" {
  input        = data.aws_availability_zones.available.names
  result_count = var.subnet_count
}


#-------- internet gateway --------#
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, map("Name", format("%s-igw", var.tags["Name"])))
}

#-------- elastic ip address for nat gateways --------#
resource "aws_eip" "nateip" {
  vpc   = true
  count = var.subnet_count * lookup(map(var.enable_nat_gateway, 1), "true", 0)
  tags  = merge(var.tags, map("Name", format("%s-nat-eip", var.tags["Name"])))
}



#-------- Create three types of subnets, three each --------#
resource "aws_subnet" "public" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    map("Name", format("%s-subnet-public-%s", var.tags["Name"], element(random_shuffle.azs.result, count.index)))
  )
}
resource "aws_subnet" "private" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 1 * length(data.aws_availability_zones.available.names))
  availability_zone = element(data.aws_availability_zones.available.names, count.index)


  tags = merge(
    var.tags,
    map("Name", format("%s-subnet-private-%s", var.tags["Name"], element(random_shuffle.azs.result, count.index)))
  )
}
resource "aws_subnet" "db" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 2 * length(data.aws_availability_zones.available.names))
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = merge(
    var.tags,
    map("Name", format("%s-subnet-db-%s", var.tags["Name"], element(random_shuffle.azs.result, count.index)))
  )
}

#-------- Create Route Tables for Public subnet --------#
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(var.tags, map("Name", format("%s-rt-public", var.tags["Name"])))
}

resource "aws_route_table_association" "public" {
  count          = var.subnet_count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}


#-------- nat gateways --------#
resource "aws_nat_gateway" "natgw" {
  count         = var.subnet_count * lookup(map(var.enable_nat_gateway, 1), "true", 0)
  allocation_id = element(aws_eip.nateip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_internet_gateway.main]
  tags          = merge(var.tags, map("Name", format("%s-ngw-%s", var.tags["Name"], element(data.aws_availability_zones.available.names, count.index))))
}


#-------- route tables for private subnets --------#
resource "aws_route_table" "internal" {
  count  = var.subnet_count * lookup(map(var.enable_nat_gateway, 1), "true", 0) # var.subnet_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw[count.index].id
  }
  tags = merge(var.tags, map("Name", format("%s-rt-internal", var.tags["Name"])))
}

resource "aws_route_table_association" "private" {
  count          = var.subnet_count * lookup(map(var.enable_nat_gateway, 1), "true", 0) # var.subnet_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.internal.*.id, count.index)
}
resource "aws_route_table_association" "db" {
  count          = var.subnet_count * lookup(map(var.enable_nat_gateway, 1), "true", 0) # var.subnet_count
  subnet_id      = element(aws_subnet.db.*.id, count.index)
  route_table_id = element(aws_route_table.internal.*.id, count.index)
}


#-------- Security Groups --------#
resource "aws_security_group" "public" {
  vpc_id      = aws_vpc.main.id
  name        = format("%s-sg-public", var.tags["Name"])
  description = "SG for External Access to VPC"
  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, map("Name", format("%s-sg-public", var.tags["Name"])))

}

resource "aws_security_group" "bastion" {
  vpc_id      = aws_vpc.main.id
  name        = format("%s-sg-bastion", var.tags["Name"])
  description = "SG for Access from Public Subnets"
  # SSH access from anywhere
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.public.id}"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, map("Name", format("%s-sg-bastion", var.tags["Name"])))

}

#-------- IAM user, group, policy --------#

resource "aws_iam_user" "name" {
  for_each = toset(var.username)
  name     = each.value
}

resource "aws_iam_access_key" "secret" {
  for_each = tomap(aws_iam_user.name)
  user     = each.key
  pgp_key = "keybase:laltopi"
}

resource "aws_iam_group" "engineering" {
  name = "Engineering"
  path = "/users/"
}

resource "aws_iam_user_group_membership" "member" {
  for_each = tomap(aws_iam_user.name)
  user     = each.key
  groups = [
    aws_iam_group.engineering.name
  ]
}

resource "aws_iam_group_policy_attachment" "eng-attach" {
  group      = aws_iam_group.engineering.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_policy" "policy" {
  name        = "s3_Eng_Access"
  path        = "/"
  description = "S3 Access Policy for Engineering"
  policy      = file("policy.json")
}


#--------------- S3 Buckets ---------------#

resource "random_string" "bucket_prefix" {
  length  = 12
  upper   = false
  special = false
  number  = true
}

locals {
  bucket_name = "engg-${random_string.bucket_prefix.result}"
}

resource "aws_s3_bucket" "main" {
  bucket        = local.bucket_name
  acl           = "private"
  force_destroy = true

  # Prevent accidental deletion, set true in production
  lifecycle {
    prevent_destroy = false
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning {
    enabled = true
  }
  tags = {
    Name    = local.bucket_name
    Purpose = "For Engg Group"
  }
  lifecycle_rule {
    id      = "state"
    prefix  = "state/"
    enabled = true

    noncurrent_version_expiration {
      days = 90
    }
  }
}

data "template_file" "bucket_policy" {
  template = "${file("${path.module}/s3_bucket_policy.tpl")}"
  vars = {
    bucket = local.bucket_name
    src_ip = "8.8.8.8/32"
  }

}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.template_file.bucket_policy.rendered
}

#--------------- Cloud Trail ---------------#

#--------------- Cloud Watch ---------------#


#--------------- Declare variables ---------------#

variable "profile" {
  default = "sandbox"
}

variable "region" {
  default = "us-east-1"
}

variable "name" {
  description = "Name of the VPC"
  default     = "area55"
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
    Name        = "area55"
    Environment = "Staging"
    AccountId   = "XYZ98760"
    RandomeCode = "YSTPLW"
  }
}

variable "enable_nat_gateway" {
  description = "Enable or Disable NAT gateway"
  default     = "true"
}

variable "dns_zone_name" {
  default     = "area55.local"
  description = "the internal dns name"
}

variable "username" {
  type    = list
  default = ["alice", "bob", "charlie"]
}

#--------------- Show Outputs ---------------#


output "vpc_id" {
  value = aws_vpc.main.id
}
/**
output "azs" {
  value = data.aws_availability_zones.available.names
}
*/

output "eip_ip" {
  value = aws_eip.nateip.*.public_ip
}

output "natgw" {
  value = aws_nat_gateway.natgw.*.id
}

/**
output "public_subnet_id" {
  value = aws_subnet.public.*.id
}


output "private_subnet_id" {
  value = aws_subnet.private.*.id
}

output "db_subnet_id" {
  value = aws_subnet.db.*.id
}

output "all_users" {
  value = tomap(aws_iam_user.name)
}
**/

output "s3_bucket" {
  value = aws_s3_bucket.main.id
}

output "secret_id_key" {
  value = aws_iam_access_key.secret["alice"].id
}