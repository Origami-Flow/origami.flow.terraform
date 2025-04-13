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

output "elastic_ip" {
  value = module.ec2_public.elastic_ip
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


