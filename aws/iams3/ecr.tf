variable "repo-name" {
  description = "Name of the ECR"
  default     = "recipe-app-api-proxy"
}

resource "aws_ecr_repository" "repo-1" {
  name                 = var.repo-name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

#-- Create a user, access key, apply policy to push into ecr -----#

data "template_file" "ecr" {
  template = file("${path.module}/ci-push-ecr-policy.tpl")
  vars = {
    resource_arn = aws_ecr_repository.repo-1.arn
    # resource_arn = "arn:aws:ecr:${var.region}:*:repository/${aws_ecr_repository.repo-1.name}"
  }
}

resource "aws_iam_policy" "ecr" {
  name        = "CI-Push-ECR"
  path        = "/"
  description = "Policy to push Docker Images from Gitlab CI-CD Pipeline"
  policy      = data.template_file.ecr.rendered
}

resource "aws_iam_user" "ecr" {
  name = "recipe-app-api-proxy-ci"
}

resource "aws_iam_access_key" "ecr" {
  user = aws_iam_user.ecr.name
}

resource "aws_iam_user_policy_attachment" "ecr" {
  user       = aws_iam_user.ecr.name
  policy_arn = aws_iam_policy.ecr.arn
}

output "ecr_user_access" {
  value = {
    "aws_access_key_id"     = aws_iam_access_key.ecr.id
    "aws_access_secret_key" = aws_iam_access_key.ecr.secret
  }
}

output "ecr_arn" {
  value = aws_ecr_repository.repo-1.arn
}

output "ecr_url" {
  value = aws_ecr_repository.repo-1.repository_url
}
