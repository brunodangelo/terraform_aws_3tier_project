output "lb_dns" {
  description = "Dirección dns del Load Balancer externo"
  value = module.ec2.dns_external_lb
}