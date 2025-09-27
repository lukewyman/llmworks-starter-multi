locals {
  # flip these in one place
  aws_region     = "us-west-2"
  project        = "llmworks-starter"
  tags = {
    Project   = local.project
    ManagedBy = "terragrunt"
  }
}
