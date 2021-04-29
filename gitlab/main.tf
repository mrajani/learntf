locals {
  gitlab_bucket = "${var.backup_s3bucket}-${random_string.bucket_prefix.result}"
}

#-------- IAM user  --------#

resource "aws_iam_user" "name" {
  name = var.username
}

resource "aws_iam_access_key" "secret" {
  user = aws_iam_user.name.id
}

#-------- IAM group  --------#

resource "aws_iam_group" "backup" {
  name = var.groupname
  path = "/"
}

#-------- IAM user, group  --------#
resource "aws_iam_user_group_membership" "member" {
  user = var.username
  groups = [
    aws_iam_group.backup.name
  ]
}

#-------- IAM Group Policy  --------#

resource "aws_iam_group_policy_attachment" "gitlab" {
  group      = aws_iam_group.backup.name
  policy_arn = aws_iam_policy.policy.arn
}

data "template_file" "iam_policy" {
  template = file("${path.module}/templates/iam_s3_policy.tpl")
  vars = {
    bucket = local.gitlab_bucket
  }
}

#-------- IAM Policy for S3 Role  --------#

resource "aws_iam_policy" "policy" {
  name        = "Gitlab_Backup"
  path        = "/"
  description = "S3 Access Policy for Gitlab Backup"
  policy      = data.template_file.iam_policy.rendered
}

#-------- AWS S3 Bucket --------#

resource "aws_s3_bucket" "gitlab" {
  bucket        = local.gitlab_bucket
  acl           = "private"
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name    = local.gitlab_bucket
    Purpose = "S3 Bucket for Gitlab Backup"
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

resource "aws_s3_bucket_public_access_block" "gitlab" {
  bucket                  = aws_s3_bucket.gitlab.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


#-------- S3 Bucket Policy   --------# 
data "template_file" "bucket_policy" {
  template = file("${path.module}/templates/s3_bucket_policy.tpl")
  vars = {
    region = var.region
    bucket = local.gitlab_bucket
    src_ip = format("%s/%s", "0.0.0.0", "32") # Enter a range or src_ip
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.gitlab.id
  policy = data.template_file.bucket_policy.rendered
}

#-------- Variables and Locals --------#
resource "random_string" "bucket_prefix" {
  length  = 6
  upper   = false
  special = false
  number  = true
}

