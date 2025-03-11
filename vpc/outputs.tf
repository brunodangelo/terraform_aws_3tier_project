output "public_subnets_id" {
  description = "IDs de las subnets publicas creadas"
  value = aws_subnet.public-subnet.*.id
}

output "private_subnets_id" {
  description = "IDs de las subnets privadas creadas"
  value = aws_subnet.private-subnet.*.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}