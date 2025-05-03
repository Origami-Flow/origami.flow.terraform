terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = ">= 5.79.0"
        }
    }
    required_version = ">= 1.2.0"
}

provider "aws" {
    region = "us-east-1"
}

module "network" { 
 source = "./modules/network"
}

module "keypair" {
  source = "./modules/keypair"
  aws_access_key = "mysshkey"
}

module "ec2_public" {
  source            = "./modules/ec2"
  ami_id            = "ami-084568db4383264d4" 
  instance_type     = "t2.micro"
  key_pair_name     = module.keypair.aws_access_key
  instance_name     = "public_app"
  subnet_id         = module.network.public_subnet_id
  security_group_id = module.network.public_security_group_id
  has_public_ip     = true
}

module "ec2_private" {
  source            = "./modules/ec2"
  ami_id            = "ami-084568db4383264d4" 
  instance_type     = "t2.micro"
  key_pair_name     = module.keypair.aws_access_key
  instance_name     = "private_app"
  subnet_id         = module.network.private_subnet_id
  security_group_id = module.network.private_security_group_id
} 

module "ec2_private_2" {
  source            = "./modules/ec2"
  ami_id            = "ami-084568db4383264d4" 
  instance_type     = "t2.micro"
  key_pair_name     = module.keypair.aws_access_key
  instance_name     = "private_app_2"
  subnet_id         = module.network.private_subnet_id
  security_group_id = module.network.private_security_group_id
} 

module "ec2_private_auth" {
  source            = "./modules/ec2"
  ami_id            = "ami-084568db4383264d4" 
  instance_type     = "t2.micro"
  key_pair_name     = module.keypair.aws_access_key
  instance_name     = "private_auth_app"
  subnet_id         = module.network.private_subnet_id
  security_group_id = module.network.private_security_group_id
} 


output "public_ip_ec2_public" {
  value = module.ec2_public.public_ip
  description = "Public IP address of the EC2 instance."
}

output "private_ip_ec2_private" {
  value = module.ec2_private.private_ip
  description = "Private IP address of the EC2 instance."
}

output "private_ip_ec2_private_2" {
  value = module.ec2_private_2.private_ip
  description = "Private IP address of the second EC2 instance."
}

output "private_ip_ec2_private_auth" {
  value = module.ec2_private_auth.private_ip
  description = "Private IP address of the private authentication EC2 instance."
} 
