variable "secrethub_user" {

}

provider "secrethub" {
  version    = "~> 0.2.0"
  credential = file("~/.secrethub/credential")
}

resource "secrethub_secret" "db_password" {
  path = "${var.secrethub_user}/start/db-password"

  generate {
    length      = 22
    use_symbols = true
  }
}

resource "secrethub_secret" "db_user" {
  path  = "${var.secrethub_user}/start/db-user"
  value = "mydbuser"
}

output "db_password" {
  value = "${secrethub_secret.db_password.value}"
}

output "db_user" {
  value = "${secrethub_secret.db_user.value}"
}

