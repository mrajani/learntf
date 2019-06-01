##################################################################################
# OUTPUTs
##################################################################################

output "netadmin-access-key" {
  value = "${aws_iam_access_key.netadmin.id}"
}

output "netadmin-secret-key" {
  value = "${aws_iam_access_key.netadmin.secret}"
}

output "appadmin-access-key" {
  value = "${aws_iam_access_key.appadmin.id}"
}

output "appadmin-secret-key" {
  value = "${aws_iam_access_key.appadmin.secret}"
}
