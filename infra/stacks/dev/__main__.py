from __future__ import annotations

import pulumi
from components.eks import Eks
from components.vpc import Vpc
from pulumi import Config

cfg = Config()
region = cfg.require("awsRegion")
vpc_cidr = cfg.get("vpcCidr") or "10.42.0.0/16"
azs = cfg.get_object("azs") or [f"{region}a", f"{region}b"]
cluster_name = cfg.get("clusterName") or "llmworks-dev"
cluster_version = cfg.get("clusterVersion") or "1.29"

node_desired_size = int(cfg.get("nodeDesiredSize") or 2)
node_min_size = int(cfg.get("nodeMinSize") or 1)
node_max_size = int(cfg.get("nodeMaxSize") or 3)
node_instance_types = cfg.get_object("nodeInstanceTypes") or ["t3.small"]
node_capacity_type = cfg.get("nodeCapacityType") or "SPOT"

vpc = Vpc(
    "net",  # resource_name (Pulumi-internal)
    name=cluster_name,  # TF-style name used in tags/ids
    region=region,
    vpc_cidr=vpc_cidr,
    azs=azs,
)

eks = Eks(
    "eks",
    region=region,
    cluster_name=cluster_name,
    cluster_version=cluster_version,
    vpc_id=vpc.vpc_id,
    private_subnets=vpc.private_subnets,  # control plane + default node subnets
    # node_subnets omitted → defaults to private_subnets now
    node_group_name="default",
    node_desired_size=node_desired_size,
    node_min_size=node_min_size,
    node_max_size=node_max_size,
    node_instance_types=node_instance_types,  # consider multiple types for SPOT
    node_capacity_type=node_capacity_type,  # SPOT or ON_DEMAND from config
)

# Expose TF-parity outputs
pulumi.export("vpc_id", vpc.vpc_id)
pulumi.export("private_subnets", vpc.private_subnets)
pulumi.export("public_subnets", vpc.public_subnets)

pulumi.export("cluster_certificate_authority_data", eks.cluster_certificate_authority_data)
pulumi.export("cluster_name", eks.cluster_name)
pulumi.export("cluster_arn", eks.cluster_arn)
pulumi.export("cluster_endpoint", eks.cluster_endpoint)
pulumi.export("cluster_id", eks.cluster_id)
pulumi.export("oidc_provider_arn", eks.oidc_provider_arn)
