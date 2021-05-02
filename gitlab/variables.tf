variable "profile" {
  default = "default"
}
variable "region" {
  default = "us-east-1"
}

variable "username" {
  default = "gitlab"
}

variable "groupname" {
  default = "gitlab"
}
variable "backup_s3bucket" {
  default = "gitlab-s3backup"
}

variable "gpg_key" {
  default = null
}
