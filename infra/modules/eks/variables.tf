variable "cluster_name" {
  type = string
}
variable "cluster_version" {
  type    = string
  default = "1.30"
}
variable "vpc_id" {
  type = string
}
variable "private_subnets" {
  type = list(string)
}
variable "node_groups" {
  description = <<EOT
Map of EKS managed node groups. Example:
{
  default = {
    desired_size   = 2
    min_size       = 1
    max_size       = 3
    capacity_type  = "SPOT"
    instance_types = ["m5.large","m5a.large"]
  }
}
EOT
  type = map(object({
    desired_size   = number
    min_size       = number
    max_size       = number
    capacity_type  = string        # "SPOT" | "ON_DEMAND"
    instance_types = list(string)
  }))
}
variable "tags" {
  type    = map(string)
  default = {}
}
