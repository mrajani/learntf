variable "profile" {}
variable "region" {}
variable "name" {}
variable "key_pair_path" {}
variable "tags" {
  description = "A map of tags to add to all resources"
  default = {
    Name        = ""
    Environment = ""
    AccountId   = ""
    RandomeCode = ""
  }
}
