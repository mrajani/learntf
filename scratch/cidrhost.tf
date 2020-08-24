##############################################
# Function: cidrhost
##############################################
##############################################
# Variables
##############################################
variable "iprange" {
  default = "10.0.0.0/16"
}

variable "hostnum" {
  default = 2
}

##############################################
# Resources
##############################################

##############################################
# Outputs
##############################################
output "iprange_1" {
  value = "${var.iprange}"
}

output "hostnum_2" {
  value = "${var.hostnum}"
}

output "cidrhost_output_3" {
  value = "${cidrhost(var.iprange, var.hostnum)}"
}
