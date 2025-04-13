variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "value"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "Name of the key pair to use for SSH access"
  type = string
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type = string
}

variable "security_group_id" {
  description = "value of the security group to use for the EC2 instance"
  type = string
}

variable "av_zone" {
  description = "Availability zone for the EC2 instance"
  type        = string
  default     = "us-east-1a"
}

variable "has_public_ip" {
  description = "Whether to assign a public IP address to the EC2 instance"
  type    = bool
  default = false
}

