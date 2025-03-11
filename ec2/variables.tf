variable "max_amount_ec2" {
  description = "Cantidad de instancias EC2 a crear"
  type = number
}

variable "public_subnets_id" {
  description = "IDs de las subnets creadas"
  type = list(string)
}

variable "private_subnets_id" {
  description = "IDs de las subnets privadas creadas"
  type = list(string)
}

variable "vpc_id" {
  description = "ID de la vpc donde se despliegan las instancias ec2"
  type = string
}

variable "availability_zones" {
  description = "Zonas de disponibilidad donde se desplegan los recursos"
  type = list(string)
}