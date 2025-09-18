# llmworks-starter-multi / infra

Stacks are **dev**, **stg**, **prod**. Region & other params are Pulumi config.

## Quick start
```bash
cd infra
pulumi login                               # local or Pulumi Cloud
pulumi stack init dev
pulumi config set llmworks-starter-multi:awsRegion us-west-2
pulumi preview
