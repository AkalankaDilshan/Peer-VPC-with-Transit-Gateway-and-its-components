# Critical Security Alerts 
resource "aws_sns_topic" "security_alerts" {
  name = "VPCSecurityAlerts"
}

# Non-Critical Performance Alerts 
resource "aws_sns_topic" "Performance_alerts" {
  name = "NetworkPerformanceAlerts"
}
