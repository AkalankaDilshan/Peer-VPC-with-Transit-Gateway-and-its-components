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
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  type        = string
}

variable "private_subnet_cidrs" {
  type        = string
  description = "cidr values for private subnet"
}

# variable "aws_region" {
#   type        = string
#   description = "region for deploye vpc"
# }
