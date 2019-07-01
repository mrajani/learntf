output "vpc_id" {
  value = aws_vpc.main.id
}
output "azs" {
  value = data.aws_availability_zones.available.names
}

output "eip_ip" {
  value = aws_eip.nateip.*.public_ip
}

output "natgw" {
  value = aws_nat_gateway.natgw.*.id
}

output "public_subnet_id" {
  value = aws_subnet.public.*.id
}


output "private_subnet_id" {
  value = aws_subnet.private.*.id
}

output "db_subnet_id" {
  value = aws_subnet.db.*.id
}