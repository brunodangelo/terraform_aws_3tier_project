module "vpc" {
  source = "./vpc"
  availability_zones = var.availability_zones
}

module "ec2" {
  source = "./ec2"
  max_amount_ec2 = var.max_ec2
  public_subnets_id = module.vpc.public_subnets_id
  private_subnets_id = module.vpc.private_subnets_id
  vpc_id = module.vpc.vpc_id
  availability_zones = var.availability_zones
}

module "dynamodb" {
  source = "./dynamodb"
  availability_zones = var.availability_zones
}