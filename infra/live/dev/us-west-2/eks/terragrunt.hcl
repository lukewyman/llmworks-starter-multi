include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  region      = include.root.locals.region
  name_prefix = include.root.locals.name_prefix
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id          = "vpc-00000000000000000"
    private_subnets = ["subnet-aaaaaaaa","subnet-bbbbbbbb","subnet-cccccccc"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

terraform {
  source = "../../../../modules/eks"
}

inputs = {
  region          = local.region
  cluster_name    = local.name_prefix
  cluster_version = "1.29"
  vpc_id          = dependency.vpc.outputs.vpc_id
  private_subnets = dependency.vpc.outputs.private_subnets

  # Optional overrides:
  node_group_name     = "default"
  node_desired_size   = 2
  node_min_size       = 1
  node_max_size       = 3
  node_instance_types = ["m5.large"]
  node_capacity_type  = "SPOT"
}
