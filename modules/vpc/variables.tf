variable "vpc_name" {
  description = "name for vpc"
  type        = string
}

variable "cidr_block" {
  description = "CIDR address for vpc"
  type        = string
}

variable "availability_zones" {
  description = "availability_zones"
  type        = list(string)
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "cidr values for private subnet"
}

variable "enable_NAT_gateway" {
  type        = bool
  description = "NAT gateway available or not"
  default     = false
}

# variable "aws_region" {
#   type        = string
#   description = "region for deploye vpc"
# }
