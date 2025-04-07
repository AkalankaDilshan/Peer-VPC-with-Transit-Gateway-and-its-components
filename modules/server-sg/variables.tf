variable "vpc_id" {
  description = "ec2 vpc id"
  type        = string
}

variable "security_group_name" {
  description = "name for server sg"
  type        = string
}

variable "source_sg_id" {
  description = "source sg(bastion ec2) id"
  type        = string
}
