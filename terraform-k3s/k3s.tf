module "k3s" {
  source = "../modules/k3s"

  name          = var.cluster_name
  vpc_id        = var.VPC_ID
  subnet_id     = var.SUBNET_ID
  key_name      = var.KEY_NAME
  allowed_cidrs = var.ALLOW_IPS
}