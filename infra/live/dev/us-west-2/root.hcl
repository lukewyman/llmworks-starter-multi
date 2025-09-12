locals {
  region      = "us-west-2"
  account_id  = get_aws_account_id()
  name_prefix = "llmworks-dev"

  vpc_cidr    = "10.0.0.0/16"
  azs         = ["us-west-2a", "us-west-2b", "us-west-2c"]

  state_bucket = "llmworks-terraform-state-${local.account_id}-${local.region}"
  lock_table   = "llmworks-terraform-locks"
}

# Use OpenTofu via Terragrunt
terraform {
  extra_arguments "tofu_compat" {
    commands = get_terraform_commands_that_need_vars()
    env_vars = { TF_CLI_ARGS = "" } # noop placeholder
  }
}

remote_state {
  backend = "s3"
  config = {
    bucket         = local.state_bucket
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    dynamodb_table = local.lock_table
    encrypt        = true
  }
}
