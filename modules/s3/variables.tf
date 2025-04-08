variable "bucket_prefix" {
  description = "prefix for bucket"
  type        = string
}

variable "environment" {
  description = "bucket environment"
  type        = string
  default     = "development"
}
