
resource "aws_instance" "app_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  availability_zone      = var.av_zone 
  
  ebs_block_device {
        device_name         = "/dev/sda1"
        volume_size         = 30
        volume_type         = "standard"
    }

  subnet_id              = var.subnet_id
  associate_public_ip_address = var.has_public_ip
  key_name               = var.key_pair_name
  vpc_security_group_ids = [var.security_group_id]

  user_data              = file("${path.module}/script.sh")

  tags = {
    Name = var.instance_name
  }
}
