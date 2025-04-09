resource "aws_flow_log" "tgw_flow_log_cloudwatch" {
  transit_gateway_id = var.transit_gateway_id
  # transit_gateway_attachment_id = var.transit_gateway_attachment_id
  log_destination          = var.cloudwatch_log_group_arn
  log_destination_type     = "cloud-watch-logs"
  iam_role_arn             = var.iam_role_arn
  traffic_type             = "ALL"
  max_aggregation_interval = 60
  tags = {
    Name = "TGWFlowLogToCloudWatch"
  }
}

resource "aws_flow_log" "tgw_flow_log_s3" {
  transit_gateway_id = var.transit_gateway_id
  # transit_gateway_attachment_id = var.transit_gateway_attachment_id
  log_destination          = "${var.s3_bucket_arn}/${var.s3_prefix}"
  log_destination_type     = "s3"
  traffic_type             = "ALL"
  max_aggregation_interval = 60
  tags = {
    Name = "TGWFlowLogToS3"
  }
}
