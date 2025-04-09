variable "vpc_flow_logs_name" {
  description = "vpc flowlog name for filter metrics"
  type        = string
}

variable "sns_security_alerts_arn" {
  description = "vpc sns securoty alert arn"
  type        = string
}

variable "sns_performance_alerts_arn" {
  description = "sns for performance alerts"
  type        = string
}
