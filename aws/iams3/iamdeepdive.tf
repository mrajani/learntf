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
    "admin"          = ["craig, sridhar, eva"],
    "management"     = ["zain, david, quentin"],
    "solutions-arch" = ["cenzo, usha"],
    "qa"             = ["cael, cody, shantel"],
    "graphic-design" = ["reddy, kara"],
    "dev"            = ["lou, steve, mary"]
  }
}


resource "aws_iam_group" "main" {
  for_each = tomap(var.iam_map)
  name     = each.key
  path     = "/groups/"
}

resource "aws_iam_user" "main" {
  for_each = {
    for v in values(tomap(var.iam_map)) :
    user => v
  }
  name = user.value
}