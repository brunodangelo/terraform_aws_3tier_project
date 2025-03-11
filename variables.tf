variable "availability_zones" {
  description = "Zonas de Disponibilidad a trabajar"
  type = list(string)
  default = [ "us-east-1a", "us-east-1b" ]
}

variable "max_ec2" {
  description = "Cantidad máxima de instancias EC2 en los ASG"
  type = number
  default = 2
}