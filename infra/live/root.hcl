locals {
  aws_region = "us-west-2"
  project    = "llmworks-starter"
  tags = {
    Project   = local.project
    ManagedBy = "terragrunt"
  }
}

remote_state {
  backend = "s3"

  generate = {
    path = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket         = "llmworks-terraform-state-${get_aws_account_id()}-${local.aws_region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "llmworks-terraform-locks"
  }
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.6.0"
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = ">= 5.0"
        }
      }
    }
  EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.aws_region}"
    }
  EOF
}
