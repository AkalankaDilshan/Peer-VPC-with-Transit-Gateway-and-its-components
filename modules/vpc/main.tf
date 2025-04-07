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
    Name = "${var.vpc_name}-public-route-table"
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

# resource "aws_route" "private_route" {
#   route_table_id         = aws_route_table.private_rt.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.nat_gateway.id
# }

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
