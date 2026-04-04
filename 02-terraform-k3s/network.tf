module "network" {
  source = "../modules/network"

  region    = var.AWS_REGION
  allow_ips = var.ALLOW_IPS
}
