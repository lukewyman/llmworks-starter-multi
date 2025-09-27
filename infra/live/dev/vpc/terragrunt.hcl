include "root" { path = find_in_parent_folders("root.hcl") }

locals {
  root = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  aws_region = local.root.locals.aws_region
  tags       = local.root.locals.tags
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  name       = "dev-vpc"
  cidr_block = "10.42.0.0/16"
  azs        = ["${local.aws_region}a", "${local.aws_region}b"]

  private_subnets = ["10.42.1.0/24", "10.42.2.0/24"]
  public_subnets  = ["10.42.101.0/24", "10.42.102.0/24"]

  enable_nat_gateways = true
  single_nat_gateway  = true

  tags = local.tags
}
