# =============================================================================
# Outputs - EKS Cluster
# =============================================================================
output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_security_group_id" {
  description = "EKS managed cluster security group ID"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_oidc_issuer" {
  description = "OIDC issuer URL do cluster (útil p/ IRSA, etc.)"
  value       = try(aws_eks_cluster.main.identity[0].oidc[0].issuer, null)
}

output "cluster_ca_data" {
  description = "Certificate authority data (base64)"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

# =============================================================================
# Outputs - Node Groups
# =============================================================================
output "nodegroup_ids" {
  description = "Map of node group IDs"
  value       = { for k, v in aws_eks_node_group.this : k => v.id }
}

output "nodegroup_arns" {
  description = "Map of node group ARNs"
  value       = { for k, v in aws_eks_node_group.this : k => v.arn }
}

# =============================================================================
# Outputs - Launch Template
# =============================================================================
output "launch_template_id" {
  description = "Launch template ID for EKS workers"
  value       = aws_launch_template.eks_workers.id
}

output "launch_template_latest_version" {
  description = "Latest version of the EKS workers launch template"
  value       = aws_launch_template.eks_workers.latest_version
}
