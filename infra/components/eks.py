from __future__ import annotations

import json

import pulumi
import pulumi_aws as aws


class Eks(pulumi.ComponentResource):
    """
    Mirrors TF vars/outs for EKS w/ single managed node group.
    """

    cluster_certificate_authority_data: pulumi.Output[str]
    cluster_name: pulumi.Output[str]
    cluster_arn: pulumi.Output[str]
    cluster_endpoint: pulumi.Output[str]
    cluster_id: pulumi.Output[str]
    oidc_provider_arn: pulumi.Output[str]

    def __init__(
        self,
        name: str,
        *,
        region: str,
        cluster_name: str,
        cluster_version: str,
        vpc_id: str,
        private_subnets: list[str],
        node_group_name: str = "default",
        node_desired_size: int = 2,
        node_min_size: int = 1,
        node_max_size: int = 3,
        node_instance_types: list[str] = ("t3.small",),
        node_capacity_type: str = "SPOT",
        opts: pulumi.ResourceOptions | None = None,
    ):
        super().__init__("llmworks:eks:Cluster", name, None, opts)

        provider = aws.Provider(
            f"{name}-aws", region=region, opts=pulumi.ResourceOptions(parent=self)
        )

        cluster_role = aws.iam.Role(
            f"{name}-cluster-role",
            assume_role_policy=json.dumps(
                {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Action": "sts:AssumeRole",
                            "Principal": {"Service": "eks.amazonaws.com"},
                            "Effect": "Allow",
                        }
                    ],
                }
            ),
            opts=pulumi.ResourceOptions(parent=self, provider=provider),
        )
        aws.iam.RolePolicyAttachment(
            f"{name}-cluster-policy",
            role=cluster_role.name,
            policy_arn="arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
            opts=pulumi.ResourceOptions(parent=cluster_role, provider=provider),
        )

        cluster = aws.eks.Cluster(
            f"{cluster_name}",
            role_arn=cluster_role.arn,
            version=cluster_version,
            vpc_config=aws.eks.ClusterVpcConfigArgs(
                subnet_ids=private_subnets,
                endpoint_public_access=True,
            ),
            opts=pulumi.ResourceOptions(parent=self, provider=provider),
        )

        node_role = aws.iam.Role(
            f"{name}-node-role",
            assume_role_policy=json.dumps(
                {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Action": "sts:AssumeRole",
                            "Principal": {"Service": "ec2.amazonaws.com"},
                            "Effect": "Allow",
                        }
                    ],
                }
            ),
            opts=pulumi.ResourceOptions(parent=self, provider=provider),
        )
        for pol in [
            "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
            "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
            "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        ]:
            aws.iam.RolePolicyAttachment(
                f"{name}-node-{pol.split('/')[-1]}",
                role=node_role.name,
                policy_arn=pol,
                opts=pulumi.ResourceOptions(parent=node_role, provider=provider),
            )

        aws.eks.NodeGroup(
            f"{cluster_name}-{node_group_name}",
            cluster_name=cluster.name,
            node_role_arn=node_role.arn,
            subnet_ids=private_subnets,
            scaling_config=aws.eks.NodeGroupScalingConfigArgs(
                desired_size=node_desired_size,
                min_size=node_min_size,
                max_size=node_max_size,
            ),
            capacity_type=node_capacity_type,
            instance_types=list(node_instance_types),
            opts=pulumi.ResourceOptions(parent=cluster, provider=provider),
        )

        # After creating `cluster`:
        cluster_info = aws.eks.get_cluster_output(
            name=cluster.name,
            opts=pulumi.InvokeOptions(provider=provider),
        )

        issuer = cluster_info.identities.apply(lambda ids: ids[0].oidcs[0].issuer)

        oidc = aws.iam.OpenIdConnectProvider(
            f"{name}-oidc",
            url=issuer,
            client_id_lists=["sts.amazonaws.com"],
            thumbprint_lists=[
                "9e99a48a9960b14926bb7f3b02e22da0afd10df6",  # pragma: allowlist secret
            ],
            opts=pulumi.ResourceOptions(parent=cluster, provider=provider),
        )

        self.cluster_name = cluster.name
        self.cluster_arn = cluster.arn
        self.cluster_endpoint = cluster.endpoint
        self.cluster_id = cluster.id
        self.cluster_certificate_authority_data = cluster.certificate_authority.apply(
            lambda c: c["data"]
        )
        self.oidc_provider_arn = oidc.arn

        self.register_outputs(
            {
                "cluster_name": self.cluster_name,
                "cluster_arn": self.cluster_arn,
                "cluster_endpoint": self.cluster_endpoint,
                "cluster_id": self.cluster_id,
                "cluster_certificate_authority_data": self.cluster_certificate_authority_data,
                "oidc_provider_arn": self.oidc_provider_arn,
            }
        )
