include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  region      = include.root.locals.region
  name_prefix = include.root.locals.name_prefix
  vpc_cidr    = include.root.locals.vpc_cidr
  azs         = include.root.locals.azs
}

terraform {
  source = "../../../../modules/vpc"
}

inputs = {
  name     = local.name_prefix
  region   = local.region
  vpc_cidr = local.vpc_cidr
  azs      = local.azs
}
