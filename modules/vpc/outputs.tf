output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "vpc_name" {
  value = var.vpc_name
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}
