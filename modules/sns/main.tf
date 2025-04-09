# Critical Security Alerts 
resource "aws_sns_topic" "security_alerts" {
  name = "VPCSecurityAlerts"
}

# Non-Critical Performance Alerts 
resource "aws_sns_topic" "Performance_alerts" {
  name = "NetworkPerformanceAlerts"
}

resource "aws_sns_topic_subscription" "security_email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = var.email_endpoint
}

resource "aws_sns_topic_subscription" "performance_email" {
  topic_arn = aws_sns_topic.Performance_alerts.arn
  protocol  = "email"
  endpoint  = var.email_endpoint
}
