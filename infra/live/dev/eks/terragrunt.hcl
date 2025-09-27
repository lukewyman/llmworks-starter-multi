include { path = find_in_parent_folders("root.hcl") }

locals {
  root       = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  aws_region = local.root.locals.aws_region
  tags       = local.root.locals.tags
}

terraform {
  source = "../../../modules/eks"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id          = "vpc-00000000000000000"
    private_subnets = ["subnet-00000000000000000a", "subnet-00000000000000000b"]
  }

  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate"]
}

inputs = {
  cluster_name    = "dev-cluster"
  cluster_version = "1.30"

  vpc_id          = dependency.vpc.outputs.vpc_id
  private_subnets = dependency.vpc.outputs.private_subnets

  node_groups = {
    default = {
      desired_size   = 2
      min_size       = 1
      max_size       = 3
      capacity_type  = "SPOT"
      instance_types = ["m5.large", "m5a.large", "m5n.large"]
    }
  }

  tags = local.tags
}
