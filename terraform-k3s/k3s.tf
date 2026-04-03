module "k3s" {
  source = "../modules/k3s"

  name          = var.cluster_name
  vpc_id        = module.network.vpc_id
  subnet_id     = module.network.public_subnet_ids[0]
  key_name      = aws_key_pair.k3s.key_name
  allowed_cidrs = var.ALLOW_IPS

  extra_ingress_rules = [
    {
      description = "Kubernetes NodePort range"
      from_port   = 30000
      to_port     = 32767
      protocol    = "tcp"
      cidr_blocks = var.ALLOW_IPS
    }
  ]
}