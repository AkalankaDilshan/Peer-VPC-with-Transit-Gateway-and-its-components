resource "aws-route" "vpc_a_public_to_tgw" {
  route_table_id         = var.vpc_a_rt_id
  destination_cidr_block = var.vpc_b_id
  transit_gateway_id     = var.tgw_id
}

resource "aws-route" "vpc_b_public_to_tgw" {
  route_table_id         = var.vpc_b_rt_id
  destination_cidr_block = var.vpc_a_id
  transit_gateway_id     = var.tgw_id
}
