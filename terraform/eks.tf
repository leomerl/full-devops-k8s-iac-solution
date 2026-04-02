module "eks" {
  source = "../modules/eks"

  name                         = var.cluster_name
  kubernetes_version           = var.cluster_version
  vpc_id                       = module.network.vpc_id
  private_subnet_ids           = module.network.private_subnet_ids
  instance_types               = var.DEFAULT_INSTANCE.instance_type
  capacity_type                = var.capacity_type
  ami_release_version          = var.ami_release_version
  remote_network_cidr          = var.remote_network_cidr
  remote_pod_cidr              = var.remote_pod_cidr
  endpoint_public_access_cidrs = var.ALLOW_IPS
}
