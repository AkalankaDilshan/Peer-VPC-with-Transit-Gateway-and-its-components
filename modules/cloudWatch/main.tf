# ---1.METRIC FILTERS (high_rejected_connections)---
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

# ---1.ALARMS ---
resource "aws_cloudwatch_metric_alarm" "alert_rejected_connections" {
  alarm_name          = "HgihRejectedConnectionsAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "RejectedConnectionsCount"
  namespace           = "Custom/VPCFlowLogs"
  period              = "300"
  statistic           = "Sum"
  threshold           = "100"
  alarm_description   = "Security alert: High rejected connection (possible breach)"
  alarm_actions       = [var.sns_security_alerts_arn]
}

# --- 2.METRIC FILTERS (DDoS-Possible-HighBytesIn) ---
resource "aws_cloudwatch_log_metric_filter" "bytes_in_anomaly" {
  name           = "BytesInAnomaly"
  pattern        = "[version, account, eni, srcaddr, dstaddr, srcport, dstport, protocol, packets, bytes, start, end, action, log_status]"
  log_group_name = var.vpc_flow_logs_name

  metric_transformation {
    name      = "BytesInPerMinute"
    namespace = "Custom/VPCFlowLogs"
    value     = "$bytes"
  }
}

