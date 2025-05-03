
output "public_ip" {
  value = aws_instance.app_instance.public_ip
  depends_on  = [aws_instance.app_instance]
  description = "Public IP address of the EC2 instance."
  sensitive   = false
}

output "private_ip" {
  value       = aws_instance.app_instance.private_ip
  depends_on  = [aws_instance.app_instance]
  description = "Private IP address of the EC2 instance."
  sensitive   = false
}