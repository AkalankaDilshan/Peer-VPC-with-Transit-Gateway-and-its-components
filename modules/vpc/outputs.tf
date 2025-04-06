output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "vpc_name" {
  value = var.vpc_name
}

output "vpc_cidr" {
  value = aws_vpc.main_vpc.cidr_block
}


output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "public_rt_id" {
  value = aws_route_table.public_rt.id
}

output "private_rt_id" {
  value = aws_route_table.private_rt.id
}
