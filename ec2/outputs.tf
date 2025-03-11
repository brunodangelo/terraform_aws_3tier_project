output "dns_external_lb" {
  description = "DNS del Load Balancer externo"
  value = aws_lb.front_lb.dns_name
}

output "dns_internal_lb" {
  description = "DNS del Load Balancer interno"
  value = aws_lb.back_lb.dns_name
}