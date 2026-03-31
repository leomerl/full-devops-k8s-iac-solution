locals {
  remote_node_cidr = var.remote_network_cidr
  remote_pod_cidr  = var.remote_pod_cidr
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.15.1"

  name                                     = var.name
  kubernetes_version                       = var.kubernetes_version
  endpoint_private_access                  = true
  endpoint_public_access                   = length(var.endpoint_public_access_cidrs) > 0
  endpoint_public_access_cidrs             = var.endpoint_public_access_cidrs
  enable_cluster_creator_admin_permissions = true

  addons = {
    vpc-cni = {
      before_compute = true
      most_recent    = true
      configuration_values = jsonencode({
        env = {
          ENABLE_POD_ENI                    = "true"
          ENABLE_PREFIX_DELEGATION          = "true"
          POD_SECURITY_GROUP_ENFORCING_MODE = "standard"
        }
        nodeAgent = {
          enablePolicyEventLogs = "true"
        }
        enableNetworkPolicy = "true"
      })
    }
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  create_security_group      = false
  create_node_security_group = false

  security_group_additional_rules = {
    hybrid-node = {
      cidr_blocks = [local.remote_node_cidr]
      description = "Allow all traffic from remote node network"
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      type        = "ingress"
    }
    hybrid-pod = {
      cidr_blocks = [local.remote_pod_cidr]
      description = "Allow all traffic from remote pod network"
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      type        = "ingress"
    }
  }

  node_security_group_additional_rules = {
    hybrid_node_rule = {
      cidr_blocks = [local.remote_node_cidr]
      description = "Allow all traffic from remote node network"
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      type        = "ingress"
    }
    hybrid_pod_rule = {
      cidr_blocks = [local.remote_pod_cidr]
      description = "Allow all traffic from remote pod network"
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      type        = "ingress"
    }
  }

  remote_network_config = {
    remote_node_networks = {
      cidrs = [local.remote_node_cidr]
    }
    remote_pod_networks = {
      cidrs = [local.remote_pod_cidr]
    }
  }

  eks_managed_node_groups = {
    default = {
      instance_types           = var.instance_types
      force_update_version     = true
      ami_release_version      = var.ami_release_version
      use_name_prefix          = false
      iam_role_name            = "${var.name}-ng-default"
      iam_role_use_name_prefix = false

      min_size     = 1
      max_size     = 3
      desired_size = 2

      update_config = {
        max_unavailable_percentage = 50
      }

      labels = {
        workshop-default = "yes",
        owner = "levy"
      }
    }
  }

  tags = merge(var.tags, {
    "karpenter.sh/discovery" = var.name
  })
}
