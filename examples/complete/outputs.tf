output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "cluster_version" {
  description = "Kubernetes version running on the cluster"
  value       = module.eks.cluster_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS control plane"
  value       = module.eks.cluster_security_group_id
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL — needed for IRSA and Pod Identity"
  value       = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider — use when creating IRSA roles"
  value       = module.eks.oidc_provider_arn
}

output "node_groups" {
  description = "Map of created node groups with status and scaling config"
  value       = module.eks.node_groups
}

output "node_group_ids" {
  description = "Map of node group names to IDs"
  value       = module.eks.node_group_ids
}

output "cluster_addons" {
  description = "Installed EKS add-ons with versions"
  value       = module.eks.cluster_addons
}

output "launch_template_id" {
  description = "ID of the node launch template"
  value       = module.eks.launch_template_id
}

output "launch_template_latest_version" {
  description = "Latest version of the node launch template"
  value       = module.eks.launch_template_latest_version
}

output "kubeconfig_command" {
  description = "Run this command to configure kubectl"
  value       = module.eks.kubeconfig_command
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded cluster CA certificate"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}
