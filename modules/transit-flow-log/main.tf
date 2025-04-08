resource "aws_ec2_transit_gateway_flow_log" "tgw_flow_log_cloudwatch" {
  transit_gateway_id            = var.transit_gateway_id
  transit_gateway_attachment_id = var.transit_gateway_attachment_id
  log_destination               = var.cloudwatch_log_group_arn
  iam_role_arn                  = var.iam_role_arn
  traffic_type                  = "ALL"
}

resource "aws_ec2_transit_gateway_flow_log" "tgw_flow_log_s3" {
  transit_gateway_id            = var.transit_gateway_id
  transit_gateway_attachment_id = var.transit_gateway_attachment_id
  log_destination               = var.s3_bucket_arn
  traffic_type                  = "ALL"
}
