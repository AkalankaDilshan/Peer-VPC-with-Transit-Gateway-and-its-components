resource "aws_vpc" "main_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = element(var.public_subnet_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "public subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "private subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

// public route table 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_rt_association" {
  count          = length(aws_subnet.public_subnet[*].id)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

// private route table 
resource "aws_eip" "elastic_IP_address" {
  count  = var.enable_NAT_gateway ? length(var.public_subnet_cidr) : 0
  domain = "vpc"
  tags = {
    Name = "${var.vpc_name}-vpc-nat-eip-${count.index}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.enable_NAT_gateway ? length(var.public_subnet_cidr) : 0
  allocation_id = aws_eip.elastic_IP_address[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  tags = {
    Name = "${var.vpc_name}-nat-gw${count.index}"
  }
}

resource "aws_route_table" "private_rt" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index % length(aws_nat_gateway.nat_gateway)].id
  }
  tags = {
    Name = "${var.vpc_name}-private-rt-${count.index}"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt[count.index % length(aws_route_table.private_rt)].id
}

# Network ACL Section 
resource "aws_network_acl" "vpc_acl" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.vpc_name}-NACL"
  }
}

resource "aws_network_acl_rule" "public_http_inbound" {
  network_acl_id = aws_network_acl.vpc_acl.id
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "6"
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_https_inbound" {
  network_acl_id = aws_network_acl.vpc_acl.id
  rule_number    = 110
  rule_action    = "allow"
  protocol       = "6"
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_ssh_inbound" {
  network_acl_id = aws_network_acl.vpc_acl.id
  rule_number    = 120
  rule_action    = "allow"
  protocol       = "6" #TCP 
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "public_icmp_inbound" {
  network_acl_id = aws_network_acl.vpc_acl.id
  rule_number    = 90
  rule_action    = "allow"
  protocol       = "1" # ICMP
  egress         = false
  cidr_block     = "0.0.0.0/0" # Or the CIDR of the *other* VPC
  from_port      = -1
  to_port        = -1
}

resource "aws_network_acl_rule" "public_deny_all_inbound" {
  network_acl_id = aws_network_acl.vpc_acl.id
  rule_number    = 300
  rule_action    = "deny"
  protocol       = "-1"
  egress         = false
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "public_allow_all_outbound" {
  network_acl_id = aws_network_acl.vpc_acl.id
  rule_number    = 200
  rule_action    = "allow"
  protocol       = "-1"
  egress         = true
  cidr_block     = "0.0.0.0/0"
}


# Trasit gateway Attachment 
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_attachment" {
  subnet_ids         = [for s in aws_subnet.private_subnet : s.id]
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.main_vpc.id
  dns_support        = "enable"
  tags = {
    Name = "tgw-${var.vpc_name}-attachment"
  }
  depends_on = [aws_subnet.private_subnet]
}

# resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "accept_vpc" {
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.vpc_attachment.id
#   tags = {
#     Name = "tgw-vpc-a-accepter"
#   }
# }

# update route for peering vpc through transit gateway 

#*********for connect public subnet ec2s************
resource "aws_route" "tgw_peering_route_public" {
  count                  = length(var.tgw_destination_cidr)
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = var.tgw_destination_cidr[count.index]
  gateway_id             = var.transit_gateway_id
}

#******for private subnets*************
# resource "aws_route" "tgw_peering_route_private" {
#   for_each = {
#     for pair in setproduct(range(length(var.private_subnet_cidrs)), var.var.tgw_destination_cidr) :
#     "${pair[0]}-${pair[1]}" => {
#       rt_index = pair[0]
#       cidr     = pair[1]
#     }
#   }

#   route_table_id         = aws_route_table.private_rt[each.value.rt_index].id
#   destination_cidr_block = each.value.cidr
#   gateway_id             = var.transit_gateway_id
# }
