variable "transit_gateway_id" {
  description = "transit gateway id"
  type        = string
}

variable "transit_gateway_attachment_id" {
  description = "transit_gateway_attachment_id"
  type        = string
}

variable "cloudwatch_log_group_arn" {
  description = "log group arn"
  type        = string
}

variable "iam_role_arn" {
  description = "iam role arn for transit gateway work flow"
  type        = string
}

variable "s3_bucket_arn" {
  description = "for save flow logs"
  type        = string
}
