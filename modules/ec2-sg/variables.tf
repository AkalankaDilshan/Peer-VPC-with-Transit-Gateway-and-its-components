variable "vpc_id" {
  description = "main vpc id"
  type        = string
}

variable "security_group_name" {
  description = "name for web sg"
  type        = string
}

variable "is_allow_http" {
  description = "is allow HTTP rule for EC2 security group"
  type        = bool
  default     = true
}

variable "is_allow_https" {
  description = "is allow HTTPS rule for EC2 security group"
  type        = bool
  default     = true
}
