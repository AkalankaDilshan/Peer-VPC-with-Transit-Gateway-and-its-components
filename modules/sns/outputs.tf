output "sns_performance_alerts_arn" {
  value = aws_sns_topic.Performance_alerts.arn
}

output "sns_security_alerts_arn" {
  value = aws_sns_topic_subscription.security_email.arn
}
