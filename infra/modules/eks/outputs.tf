output "cluster_name" {
  value = module.eks.cluster_name
}
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
output "cluster_arn" {
  value = module.eks.cluster_arn
}
output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}
output "cluster_id" {
  value =  module.eks.cluster_id
}
output "cluster_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}
output "node_group_names" {
  value = keys(module.eks.eks_managed_node_groups)
}