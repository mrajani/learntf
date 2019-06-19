output "azs" {
  value = data.aws_availability_zones.available.names
}

output "eip_ip" {
  value = [aws_eip.nateip.*.public_ip]
}

output "natgw" {
  value = [aws_nat_gateway.natgw.*.id]
}