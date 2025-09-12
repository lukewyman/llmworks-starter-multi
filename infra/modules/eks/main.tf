terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = var.region }

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnets

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  # Core managed add-ons (already added earlier)
  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }

  # 🔹 Default managed node groupe
  eks_managed_node_groups = {
    (var.node_group_name) = {
      desired_size = var.node_desired_size
      min_size     = var.node_min_size
      max_size     = var.node_max_size

      instance_types = var.node_instance_types
      capacity_type  = var.node_capacity_type # ON_DEMAND or SPOT

      ami_type   = "AL2_x86_64"        # good default; options: AL2_x86_64_GPU, BOTTLEROCKET_x86_64, etc.
      subnet_ids = var.private_subnets # keep nodes in private subnets
    }
  }
}
