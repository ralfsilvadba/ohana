output "vpc_id" {
  value = aws_vpc.ohana.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "route_table_id" {
  value = aws_route_table.public.id
}

output "security_group_id" {
  value = aws_security_group.sg_ohana.id
}

output "elastic_ip" {
  value = aws_eip.eip_ohana.public_ip
}
