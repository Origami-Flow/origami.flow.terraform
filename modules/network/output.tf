output "main_vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
  
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
  
}

output "public_security_group_id" {
  value = aws_security_group.public_security.id
}

output "private_security_group_id" {
  value = aws_security_group.private_security.id
  
}

output "gw_nat_id" {
  value = aws_nat_gateway.gw_nat.id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}