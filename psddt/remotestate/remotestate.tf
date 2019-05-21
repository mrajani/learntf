##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${file("${var.creds_path}")}"
}

/* Define our vpc */
resource "aws_vpc" "vpc_main" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.prefix}-vpc-main"
  }
}

##################################################################################
# RESOURCES
##################################################################################
resource "aws_dynamodb_table" "terraform_statelock" {
  name           = "${var.aws_dynamodb_table}"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Name = "TF Locktable Backend"
  }
}

resource "aws_s3_bucket" "ddtnet" {
  bucket        = "${var.aws_networking_bucket}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "ReadforAppTeam",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.netadmin.arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.aws_networking_bucket}/*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.appadmin.arn}"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_networking_bucket}",
                "arn:aws:s3:::${var.aws_networking_bucket}/*"
            ]
        }
    ]
}
EOF

  tags {
    Name = "${var.prefix}-ddt-s3-net"
  }
}

resource "aws_s3_bucket" "ddtapp" {
  bucket        = "${var.aws_application_bucket}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "ReadforNetTeam",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.appadmin.arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.aws_application_bucket}/*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.netadmin.arn}"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_application_bucket}",
                "arn:aws:s3:::${var.aws_application_bucket}/*"
            ]
        }
    ]
}
EOF

  tags {
    Name = "${var.prefix}-ddt-s3-app"
  }
}

resource "aws_iam_group" "ec2admin" {
  name = "EC2Admin"
}

resource "aws_iam_group_policy_attachment" "ec2admin-attach" {
  group      = "${aws_iam_group.ec2admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group" "s3admin" {
  name = "S3Admin"
}

resource "aws_iam_group_policy_attachment" "s3admin-attach" {
  group      = "${aws_iam_group.s3admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user" "netadmin" {
  name = "netadmin"

  tags {
    Name = "Admin for Networking"
  }
}

resource "aws_iam_user_policy" "netadmin_rw" {
  name = "netadmin"
  user = "${aws_iam_user.netadmin.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_application_bucket}",
                "arn:aws:s3:::${var.aws_application_bucket}/*"
            ]
        },
                {
            "Effect": "Allow",
            "Action": ["dynamodb:*"],
            "Resource": [
                "${aws_dynamodb_table.terraform_statelock.arn}"
            ]
        }
   ]
}
EOF
}

resource "aws_iam_user" "appadmin" {
  name = "appadmin"

  tags {
    Name = "Admin for Application"
  }
}

resource "aws_iam_access_key" "appadmin" {
  user = "${aws_iam_user.appadmin.name}"
}

resource "aws_iam_user_policy" "appadmin_rw" {
  name = "appadmin"
  user = "${aws_iam_user.appadmin.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_networking_bucket}",
                "arn:aws:s3:::${var.aws_networking_bucket}/*"
            ]
        },
                {
            "Effect": "Allow",
            "Action": ["dynamodb:*"],
            "Resource": [
                "${aws_dynamodb_table.terraform_statelock.arn}"
            ]
        }
   ]
}
EOF
}

resource "aws_iam_access_key" "netadmin" {
  user = "${aws_iam_user.netadmin.name}"
}

resource "aws_iam_group_membership" "add-ec2admin" {
  name = "add-ec2admin"

  users = [
    "${aws_iam_user.netadmin.name}",
  ]

  group = "${aws_iam_group.ec2admin.name}"
}

resource "local_file" "aws_keys" {
  content = <<EOF
[default]

[netadmin]
aws_access_key_id = ${aws_iam_access_key.netadmin.id}
aws_secret_access_key = ${aws_iam_access_key.netadmin.secret}

[appadmin]
aws_access_key_id = ${aws_iam_access_key.appadmin.id}
aws_secret_access_key = ${aws_iam_access_key.appadmin.secret}

EOF

  filename = "${var.user_home_path}/.aws/credentials"
}

##################################################################################
# OUTPUT
##################################################################################

output "netadmin-access-key" {
  value = "${aws_iam_access_key.netadmin.id}"
}

output "netadmin-secret-key" {
  value = "${aws_iam_access_key.netadmin.secret}"
}

output "appadmin-access-key" {
  value = "${aws_iam_access_key.appadmin.id}"
}

output "appadmin-secret-key" {
  value = "${aws_iam_access_key.appadmin.secret}"
}
