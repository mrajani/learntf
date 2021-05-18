variable "ssh_key" {
  default = "~/.ssh/MxR-KeyPair.pub"
}

variable "userlogin" {
  default = "ubuntu" # ec2-user
}

variable "db_config" {
  type = object(
    {
      user     = string
      password = string
      database = string
      hostname = string
      port     = string
    }
  )

  default = {
    user     = "sql-admin"
    password = "sql-password"
    database = "tcp"
    hostname = "sql-host"
    port     = "3306"
  }
}
