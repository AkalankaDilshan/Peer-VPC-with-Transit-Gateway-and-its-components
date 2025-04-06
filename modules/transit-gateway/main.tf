resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit Gateway for connect VPC A and VPC B"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "main-tgw"
  }
}

# attachment for vpc a 
resource "aws_ec2_transit_gateway_vpc_attachment" "VPC_A_attachment" {
  subnet_ids         = var.vpc_a_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = var.vpc_a_id
  tags = {
    Name = "tgw-vpc-a-attachment"
  }
}

# attachment for vpc b
resource "aws_ec2_transit_gateway_vpc_attachment" "VPC_B_attachment" {
  subnet_ids         = var.vpc_b_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = var.vpc_b_id
  tags = {
    Name = "tgw-vpc-b-attachment"
  }
}

# Add Routes to vpc A public and private rt 
resource "aws_route" "vpc_a_to_tgw_public_rt" {
  route_table_id         = var.vpc_a_public_rt_id
  destination_cidr_block = var.vpc_b_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id

  depends_on = [aws_ec2_transit_gateway.tgw,
    aws_ec2_transit_gateway_vpc_attachment.VPC_A_attachment,
  aws_ec2_transit_gateway_vpc_attachment.VPC_B_attachment]
}

resource "aws_route" "vpc_a_to_tgw_private_rt" {
  route_table_id         = var.vpc_a_private_rt_id
  destination_cidr_block = var.vpc_b_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id

  depends_on = [aws_ec2_transit_gateway.tgw,
    aws_ec2_transit_gateway_vpc_attachment.VPC_A_attachment,
  aws_ec2_transit_gateway_vpc_attachment.VPC_B_attachment]
}

# Add Routes to vpc B public and private rt

resource "aws_route" "vpc_b_to_tgw_public_rt" {
  route_table_id         = var.vpc_b_public_rt_id
  destination_cidr_block = var.vpc_a_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id

  depends_on = [aws_ec2_transit_gateway.tgw,
    aws_ec2_transit_gateway_vpc_attachment.VPC_A_attachment,
  aws_ec2_transit_gateway_vpc_attachment.VPC_B_attachment]
}

resource "aws_route" "vpc_b_to_tgw_private_rt" {
  route_table_id         = var.vpc_b_private_rt_id
  destination_cidr_block = var.vpc_a_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id

  depends_on = [aws_ec2_transit_gateway.tgw,
    aws_ec2_transit_gateway_vpc_attachment.VPC_A_attachment,
  aws_ec2_transit_gateway_vpc_attachment.VPC_B_attachment]
}
