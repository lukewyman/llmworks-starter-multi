# EKS via terraform-aws-eks module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  enable_irsa = true

  eks_managed_node_groups = {
    for name, ng in var.node_groups : name => {
      instance_types = ng.instance_types
      capacity_type  = ng.capacity_type
      desired_size   = ng.desired_size
      min_size       = ng.min_size
      max_size       = ng.max_size
      subnet_ids     = var.private_subnets
    }
  }

  tags = var.tags
}
