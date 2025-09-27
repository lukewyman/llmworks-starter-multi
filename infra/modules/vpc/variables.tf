variable "name" {
  type        = string
  description = "VPC name (used in tags)"
}
variable "cidr_block" {
  type        = string
  description = "VPC CIDR"
}
variable "azs" {
  type        = list(string)
  description = "AZs to use (e.g., [us-west-2a, us-west-2b])"
}
variable "private_subnets" {
  type        = list(string)
  description = "Private subnet CIDRs (one per AZ)"
}
variable "public_subnets" {
  type        = list(string)
  description = "Public subnet CIDRs (one per AZ)"
}
variable "enable_nat_gateways" {
  type        = bool
  default     = true
  description = "Whether to create NAT gateways"
}
variable "single_nat_gateway" {
  type        = bool
  default     = true
  description = "Whether to use a single NAT GW"
}
variable "tags" {
  type        = map(string)
  default     = {}
}
