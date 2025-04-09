#****************Traffic Anomalies********
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

# --- 2. ALARMS ----
resource "aws_cloudwatch_metric_alarm" "high_bytes_in" {
  alarm_name          = "DDoS-Possible-HighBytesIn"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1" # immediate alert 
  metric_name         = "BytesInPerMinute"
  namespace           = "Custom/VPCFlowLogs"
  period              = "60" # 1 min adjust it base on your baseline 
  statistic           = "Sum"
  threshold           = "100000000" # 100 MB/min (customize)
  alarm_description   = "Traffic spike detected (possible DDos)"
  alarm_actions       = [var.sns_security_alerts_arn]
}

# Anomaly Detection 

resource "aws_cloudwatch_metric_alarm" "bytes_in_anomaly_advance" {
  alarm_name          = "Anomaloud-BytesIn"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  threshold_metric_id = "e1"
  alarm_description   = "Traffic exceeds expected pattern (AWS anomaly detection)"
  alarm_actions       = [var.sns_security_alerts_arn]

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 3)"
    label       = "BytesIn (Expected Range)"
    return_data = "true"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "BytesInPerMinute"
      namespace   = "Custom/VPCFlowLogs"
      period      = "300"
      stat        = "Sum"
    }
  }
}

# TODO : Security Threats (Port Scans, Brute Force) metrics 


#*****************Performance Metrics*******

# ---1.METRIC FILTERS (HighLatency)
resource "aws-aws_cloudwatch_log_metric_filter" "high_latency" {
  name           = "HighLatencyFlows"
  pattern        = "[version, account, eni, srcaddr, dstaddr, srcport, dstport, protocol, packets, bytes, start, end, action, log_status] | filter (end - start) > 100"
  log_group_name = var.vpc_flow_logs_name

  metric_transformation {
    name      = "HighLatencyCount"
    namespace = "Custom/VPCFlowLogs"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "latency_alarm" {
  alarm_name          = "Network-HighLatency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "HighLatencyCount"
  namespace           = "Custom/VPCFlowLogs"
  period              = "60"
  statistic           = "Sum"
  threshold           = "100"
  alarm_description   = "Network latency exceeds 100ms"
  alarm_actions       = [var.sns_performance_alerts_arn]
}
