module "network" {
  source = "../modules/network"

  region    = var.AWS_REGION
  allow_ips = var.ALLOW_IPS
}

module "nat" {
  source = "../modules/nat"

  vpc_id             = module.network.vpc_id
  public_subnet_id   = module.network.public_subnet_ids[0]
  private_subnet_ids = module.network.private_subnet_ids
  allowed_cidrs      = var.ALLOW_IPS
}
