resource "aws_flow_log" "vpc_flow_log_cloudwatch" {
  for_each             = toset([var.vpc_ids])
  log_destination_type = "cloud-watch-logs"
  log_destination      = var.cloudwatch_log_group_arn
  iam_role_arn         = var.iam_role_arn
  traffic_type         = "ALL"
  vpc_id               = each.value
}

resource "aws_flow_log" "vpc_flow_log_s3" {
  for_each             = toset([var.vpc_ids])
  log_destination_type = "s3"
  log_destination      = "${var.s3_bucket_arn}/prefix"
  iam_role_arn         = var.iam_role_arn
  traffic_type         = "ALL"
  vpc_id               = each.value
}
