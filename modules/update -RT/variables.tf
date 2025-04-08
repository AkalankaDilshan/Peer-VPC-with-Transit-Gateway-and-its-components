variable "tgw_id" {
  description = "transit gateway id"
  type        = string
}

variable "vpc_a_id" {
  description = "first vpc id"
  type        = string
}

variable "vpc_b_id" {
  description = "second vpc id"
  type        = string
}

variable "vpc_a_rt_id" {
  description = "first vpc private for public route table id"
  type        = string
}
variable "vpc_b_rt_id" {
  description = "second vpc private for public route table id"
  type        = string
}
