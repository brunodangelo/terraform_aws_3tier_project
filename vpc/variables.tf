variable "cidr_block_vpc" {
  description = "CIDR de la VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "cidr_block_public_subnets" {
  description = "CIDR de la subnets publica"
  type = list(string)
  default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "cidr_block_private_subnets" {
  description = "CIDR de la subnets privadas"
  type = list(string)
  default = ["10.0.3.0/24","10.0.4.0/24"]
}

variable "cidr_block_private_subnets_db" {
  description = "CIDR de la subnets privadas de la capa database"
  type = list(string)
  default = ["10.0.5.0/24","10.0.6.0/24"]
}

variable "availability_zones" {
  description = "Zonas de disponibilidad de las subnets"
  type = list(string)
}