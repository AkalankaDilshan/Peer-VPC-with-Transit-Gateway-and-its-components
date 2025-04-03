variable "instance_name" {
  description = "name for the EC2"
  type        = string
}

variable "instance_type" {
  description = "Type of the EC2 instance"
  type        = string
}

variable "subnet_id" {
  description = "Deploy subnet id"
  type        = string
}

variable "ec2_security_group" {
  description = "sg for ec2"
  type        = string
}

variable "ebs_volume_type" {
  description = "type of instance ebs volume"
  type        = string
}

variable "ebs_volume_size" {
  description = "size of instance ebs"
  type        = string
}

variable "is_allow_public_ip" {
  description = "is it allow public ip or not"
  type        = bool
  default     = true
}

variable "key_pair_name" {
  description = "name of instance key pair"
  type        = string
}
