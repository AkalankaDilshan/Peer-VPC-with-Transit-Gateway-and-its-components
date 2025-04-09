resource "aws_cloudwatch_log_metric_filter" "high_rejected_connections" {
  name           = "HighRejectedConnections"
  pattern        = "[version, account, eni, srcaddr, dstaddr, srcport, dstport, protocol, packets, bytes, start, end, action=REJECT, log_status]"
  log_group_name = var.vpc_flow_logs_name

  metric_transformation {
    name      = "RejectedConnectionsCount"
    namespace = "Custom/VPCFlowLogs"
    value     = "1"
  }
}

resource "" "name" {

}

