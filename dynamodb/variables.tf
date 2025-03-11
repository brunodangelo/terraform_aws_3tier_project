variable "availability_zones" {
  description = "Zonas de disponiblidad utilizadas"
  type = list(string)
}

variable "aws_region_replica" {
  description = "Región de AWS para replicar la BD"
  type = string
  default = "us-east-2"
}