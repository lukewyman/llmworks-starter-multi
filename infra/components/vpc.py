# infra/components/vpc.py
from __future__ import annotations

import pulumi  # ✅ needed for ComponentResource
import pulumi_aws as aws


class Vpc(pulumi.ComponentResource):
    """
    Mirrors TF:
      vars: name, region, vpc_cidr, azs
      outs: vpc_id, private_subnets, public_subnets
    """

    vpc_id: pulumi.Output[str]
    private_subnets: pulumi.Output[list[str]]
    public_subnets: pulumi.Output[list[str]]

    def __init__(
        self,
        resource_name: str,  # Pulumi resource name (internal)
        *,
        name: str,  # TF-style name for tags/ids (human-facing)
        region: str,
        vpc_cidr: str,
        azs: list[str],
        opts: pulumi.ResourceOptions | None = None,
    ):
        super().__init__("llmworks:net:Vpc", resource_name, None, opts)

        provider = aws.Provider(
            f"{resource_name}-aws", region=region, opts=pulumi.ResourceOptions(parent=self)
        )

        vpc = aws.ec2.Vpc(
            f"{name}-vpc",
            cidr_block=vpc_cidr,
            enable_dns_support=True,
            enable_dns_hostnames=True,
            tags={"Name": f"{name}-vpc"},
            opts=pulumi.ResourceOptions(parent=self, provider=provider),
        )

        igw = aws.ec2.InternetGateway(
            f"{name}-igw",
            vpc_id=vpc.id,
            tags={"Name": f"{name}-igw"},
            opts=pulumi.ResourceOptions(parent=vpc, provider=provider),
        )

        pub_rt = aws.ec2.RouteTable(
            f"{name}-pub-rt",
            vpc_id=vpc.id,
            routes=[aws.ec2.RouteTableRouteArgs(cidr_block="0.0.0.0/0", gateway_id=igw.id)],
            tags={"Name": f"{name}-pub-rt"},
            opts=pulumi.ResourceOptions(parent=vpc, provider=provider),
        )

        public_ids: list[pulumi.Output[str]] = []
        private_ids: list[pulumi.Output[str]] = []

        def cidr(base: str, third_octet: int, prefix: int) -> str:
            ip = base.split("/")[0]
            a, b, *_ = map(int, ip.split("."))
            return f"{a}.{b}.{third_octet}.0/{prefix}"

        for i, az in enumerate(azs):
            pub = aws.ec2.Subnet(
                f"{name}-pub-{i}",
                vpc_id=vpc.id,
                availability_zone=az,
                cidr_block=cidr(vpc_cidr, i, 24),
                map_public_ip_on_launch=True,
                tags={"Name": f"{name}-pub-{i}"},
                opts=pulumi.ResourceOptions(parent=vpc, provider=provider),
            )
            aws.ec2.RouteTableAssociation(
                f"{name}-pub-rt-assoc-{i}",
                route_table_id=pub_rt.id,
                subnet_id=pub.id,
                opts=pulumi.ResourceOptions(parent=pub_rt, provider=provider),
            )
            public_ids.append(pub.id)

            pri = aws.ec2.Subnet(
                f"{name}-pri-{i}",
                vpc_id=vpc.id,
                availability_zone=az,
                cidr_block=cidr(vpc_cidr, i + 100, 24),
                map_public_ip_on_launch=False,
                tags={"Name": f"{name}-pri-{i}"},
                opts=pulumi.ResourceOptions(parent=vpc, provider=provider),
            )
            private_ids.append(pri.id)

        self.vpc_id = vpc.id
        self.public_subnets = pulumi.Output.all(*public_ids)
        self.private_subnets = pulumi.Output.all(*private_ids)

        self.register_outputs(
            {
                "vpc_id": self.vpc_id,
                "public_subnets": self.public_subnets,
                "private_subnets": self.private_subnets,
            }
        )
