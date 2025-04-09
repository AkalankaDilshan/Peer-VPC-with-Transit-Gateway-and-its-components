resource "aws_flow_log" "vpc_flow_log_cloudwatch" {
  count                = length(var.vpc_ids)
  log_destination_type = "cloud-watch-logs"
  log_destination      = var.cloudwatch_log_group_arn
  iam_role_arn         = var.iam_role_arn
  traffic_type         = "ALL"
  vpc_id               = var.vpc_ids[count.index]
  tags = {
    Name = "cloudwatch-flow-log-${var.vpc_ids[count.index]}"
  }
}

resource "aws_flow_log" "vpc_flow_log_s3" {
  count                = length(var.vpc_ids)
  log_destination_type = "s3"
  log_destination      = "${var.s3_bucket_arn}/${var.s3_prefix}"
  traffic_type         = "ALL"
  vpc_id               = var.vpc_ids[count.index]
  tags = {
    Name = "s3-flow-log-${var.vpc_ids[count.index]}"
  }
}
