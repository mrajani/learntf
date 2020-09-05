/**
variable "iam_map" {
  type = map(list(string))
  default = {
    "admin"          = ["craig, sridhar, eva"],
    "management"     = ["zain, david, quentin"],
    "solutions arch" = ["cenzo, usha"],
    "qa"             = ["cael, cody, shantel"],
    "graphic design" = ["reddy, kara"],
    "dev"            = ["lou, steve, mary"]
  }
}
 */

variable "iam_map" {
  type = map(any)
  default = {
    "admin"          = ["craig", "sridhar", "eva"],
    "management"     = ["zain", "david", "quentin"],
    "solutions-arch" = ["cenzo", "usha"],
    "qa"             = ["cael", "cody", "shantel"],
    "graphic-design" = ["reddy", "kara"],
    "dev"            = ["lou", "steve", "mary"]
  }
}

#-------- IAM Create All Groups --------#
resource "aws_iam_group" "main" {
  for_each = tomap(var.iam_map)
  name     = each.key
  path     = "/groups/"
}

#-------- IAM admin group users, accesskey --------#
resource "aws_iam_user" "admin" {
  for_each = toset([
    for v in var.iam_map["admin"] : v
  ])
  name = each.value
}

resource "aws_iam_access_key" "admin" {
  for_each = tomap(aws_iam_user.admin)
  user     = each.key
}

resource "aws_iam_user_group_membership" "admin" {
  for_each = tomap(aws_iam_user.admin)
  user     = each.key
  groups = [
    aws_iam_group.main["admin"].name
  ]
}

#-------- IAM management group users, accesskey --------#
resource "aws_iam_user" "management" {
  for_each = toset([
    for v in var.iam_map["management"] : v
  ])
  name = each.value
}

resource "aws_iam_access_key" "management" {
  for_each = tomap(aws_iam_user.management)
  user     = each.key
}

resource "aws_iam_user_group_membership" "management" {
  for_each = tomap(aws_iam_user.management)
  user     = each.key
  groups = [
    aws_iam_group.main["management"].name
  ]
}

#-------- IAM Solutions-Arch group users, accesskey --------#
resource "aws_iam_user" "solutions-arch" {
  for_each = toset([
    for v in var.iam_map["solutions-arch"] : v
  ])
  name = each.value
}

resource "aws_iam_access_key" "solutions-arch" {
  for_each = tomap(aws_iam_user.solutions-arch)
  user     = each.key
}

resource "aws_iam_user_group_membership" "solutions-arch" {
  for_each = tomap(aws_iam_user.solutions-arch)
  user     = each.key
  groups = [
    aws_iam_group.main["solutions-arch"].name
  ]
}

#-------- IAM QA group users, accesskey --------#
resource "aws_iam_user" "qa" {
  for_each = toset([
    for v in var.iam_map["qa"] : v
  ])
  name = each.value
}

resource "aws_iam_access_key" "qa" {
  for_each = tomap(aws_iam_user.qa)
  user     = each.key
}

resource "aws_iam_user_group_membership" "qa" {
  for_each = tomap(aws_iam_user.qa)
  user     = each.key
  groups = [
    aws_iam_group.main["qa"].name
  ]
}

#-------- IAM Graphic-Design group users, accesskey --------#
resource "aws_iam_user" "graphic-design" {
  for_each = toset([
    for v in var.iam_map["graphic-design"] : v
  ])
  name = each.value
}

resource "aws_iam_access_key" "graphic-design" {
  for_each = tomap(aws_iam_user.graphic-design)
  user     = each.key
}

resource "aws_iam_user_group_membership" "graphic-design" {
  for_each = tomap(aws_iam_user.graphic-design)
  user     = each.key
  groups = [
    aws_iam_group.main["graphic-design"].name
  ]
}

#-------- IAM Dev group users, accesskey --------#
resource "aws_iam_user" "dev" {
  for_each = toset([
    for v in var.iam_map["dev"] : v
  ])
  name = each.value
}

resource "aws_iam_access_key" "dev" {
  for_each = tomap(aws_iam_user.dev)
  user     = each.key
}

resource "aws_iam_user_group_membership" "dev" {
  for_each = tomap(aws_iam_user.dev)
  user     = each.key
  groups = [
    aws_iam_group.main["dev"].name
  ]
}
