
locals {
  vpc_id = aws_vpc.main_vpc.id
  public_subnet_id = aws_subnet.public_subnet.id
  private_subnet_id = aws_subnet.private_subnet.id
  igw_id = aws_internet_gateway.igw.id
  nat_gateway_id = aws_nat_gateway.gw_nat.id
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/26"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = local.vpc_id
  cidr_block        = "10.0.0.0/27"
  availability_zone = var.a_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = local.vpc_id
  cidr_block        = "10.0.0.32/27"
  availability_zone = var.a_zone

    tags = {
        Name = "private-subnet"
  }
}

resource "aws_security_group" "public_security" {
    name        = "public_security"
    vpc_id = local.vpc_id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "private_security" {
  name        = "private_security"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [ aws_security_group.public_security.id ]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [ aws_security_group.public_security.id ]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [ aws_security_group.public_security.id ]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [ aws_security_group.private_security.id ]
  }

  ingress {
  description = "Allow internal traffic between private instances"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  security_groups = [aws_security_group.private_security.id]
 }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    security_groups = [ aws_security_group.private_security.id ]
  }

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    security_groups = [ aws_security_group.public_security.id ]
    cidr_blocks = ["0.0.0.0/0"]
  } 
}


resource "aws_internet_gateway" "igw" {
  vpc_id = local.vpc_id
  tags = {
    Name = "igw-server"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = local.nat_gateway_id
  }
  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = local.igw_id
  }
  tags = {
    Name = "public-route-table"
  }
}


resource "aws_route_table_association" "pub_route_assc" {
  subnet_id      = local.public_subnet_id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "priv_route_assc" {
  subnet_id      = local.private_subnet_id
  route_table_id = aws_route_table.private_route_table.id
}


resource "aws_eip" "nat_eip" {
  domain = "vpc"
  depends_on = [ aws_internet_gateway.igw ]
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "gw_nat" {
  subnet_id     = local.public_subnet_id
  allocation_id = aws_eip.nat_eip.id
  depends_on    = [local.igw_id]

  tags = {
    Name = "gw-nat"
  }
}

resource "aws_network_acl" "public_nacl" {
  vpc_id    = local.vpc_id
  subnet_ids = [local.public_subnet_id]

  tags = {
    Name = "public-nacl"
  }
}

resource "aws_network_acl" "private_nacl" {
  vpc_id    = local.vpc_id
  subnet_ids = [local.private_subnet_id]

  tags = {
    Name = "private-nacl"
  }
}

resource "aws_network_acl_rule" "public_allow_all_inbound_rule" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"  
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_allow_all_outbound_rule" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 100  
  protocol       = "tcp" 
  egress         = true 
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_80_rule" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 200  
  protocol       = "tcp" 
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_80_outbound_rule" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 200  
  protocol       = "tcp" 
  egress         = true 
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_443_rule" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 300  
  protocol       = "tcp" 
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_443_outbound_rule" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 300  
  protocol       = "tcp" 
  egress         = true 
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_22_rule" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 400  
  protocol       = "tcp" 
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "public_22_outbound_rule" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 400  
  protocol       = "tcp" 
  egress         = true 
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

// db port
resource "aws_network_acl_rule" "port_3306_rule" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 500
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3306
  to_port        = 3306
}

//jwt port
resource "aws_network_acl_rule" "port_8081_rule" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 600
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 8081
  to_port        = 8081
}

resource "aws_network_acl_rule" "private_inbound_rule_all" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0" 
  from_port      = 0
  to_port        = 65535
}
resource "aws_network_acl_rule" "private_outbound_rule_all" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "private_to_public_inbound_rule" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 150
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/26" 
  from_port      = 3000
  to_port        = 65535
}
resource "aws_network_acl_rule" "private_to_public_outbound_rule" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 150
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     =  "10.0.0.0/26" 
  from_port      = 3000
  to_port        = 65535
}

resource "aws_network_acl_rule" "private_80_rule" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 200
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"  
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "private_80_outbound_rule" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 200
  protocol       = "tcp"
  egress         = true
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"  
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "private_443_rule" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 300
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"  
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "private_443_outbound_rule" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 300
  protocol       = "tcp"
  egress         = true
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"  
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "private_22_rule" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 400
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"  
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "private_22_outbound_rule" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 400
  protocol       = "tcp"
  egress         = true
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"  
  from_port      = 22
  to_port        = 22
}