
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


 provisioner "file" {
      source      = "aaaaaaaaaaaaa"
      destination = "/aaaa/aaaaaaaa/aaaaaaaaa"

    connection {
      type        = "ssh"
      host        = self.public_ip #????
      user        = "ubuntu"
      private_key = "${file("mysshkey.pem")}"
    }
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /aaaaa/aaaaaaa/aaaaaaaaaaaaaa",
      "sh /aaaa/aaaa/aaaaaaaa",
    ]
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = "${file("mysshkey.pem")}"
    }
  }

  tags = {
    Name = var.instance_name
  }
}
