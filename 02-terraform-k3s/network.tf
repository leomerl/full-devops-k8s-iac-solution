module "network" {
  source = "../modules/network"
  vpc_name = var.vpc_name
  igw_name = var.igw_name
  
  region    = var.AWS_REGION
  allow_ips = var.ALLOW_IPS
}
