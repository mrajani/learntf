terraform {
  required_version = "~> 0.13.0"
  required_providers {
    random   = "~> 2.2"
    template = "~> 2.1"
    local    = "~> 1.4"
    http     = "~> 1.2"
    aws      = "~> 2.32"
  }
}

#-------- Find my public IP --------#
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}


data "http" "uuid" {
  url = "https://www.uuidgenerator.net/api/version4/1"
}


output "myip" {
  value = data.http.myip.body
}

output "uuid" {
  value = data.http.uuid.body
}
