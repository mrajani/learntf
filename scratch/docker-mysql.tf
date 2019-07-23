variable "container_name" {
  description = "The MySQL container name."
  default     = "mysql"
}

variable "mysql_root_password" {
  description = "The MySQL root password."
  default     = "P4sSw0rd0!"
}

variable "mysql_network_name" {
  description = "The MySQL's network'."
  default     = "mysql_internal_network"
}

variable "mysql_volume_name" {
  description = "The MySQL's Volume'."
  default     = "mysql_data"
}

resource "docker_image" "mysql_image" {
name = "mysql:5.7"
}

resource "docker_network" "private_bridge_network" {
  name     = "${var.mysql_network_name}"
  driver   = "bridge"
  internal = true
}

resource "docker_volume" "mysql_data_volume" {
  name = "${var.mysql_volume_name}"
}

resource "docker_container" "mysql_container" {
  name  = "${var.container_name}"
  image = "${docker_image.mysql_image.name}"
  env   = [
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}"
  ]
  volumes {
    volume_name    = "${docker_volume.mysql_data_volume.name}"
    container_path = "/var/lib/mysql"
  }
  networks_advanced {
    name    = "${docker_network.private_bridge_network.name}"
  }
}

