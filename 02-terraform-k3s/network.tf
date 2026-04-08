module "network" {
  source = "../modules/network"
  vpc_name = local.vpc_name
  igw_name = local.igw_name
  
  region    = var.AWS_REGION
  allow_ips = var.ALLOW_IPS
}
