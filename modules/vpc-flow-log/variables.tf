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

variable "vpc_ids" {
  description = "all ids in vpcs"
  type        = list(string)
}

variable "s3_prefix" {
  description = "Prefix for S3 flow logs"
  type        = string
  default     = "flow-logs"
}
