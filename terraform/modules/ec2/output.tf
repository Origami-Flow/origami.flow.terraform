
output "elastic_ip" {
  value = length(aws_eip.eip) > 0 ? aws_eip.eip[0].public_ip : null
}