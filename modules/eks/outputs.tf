# =============================================================================
# Cluster Outputs
# =============================================================================
output "cluster_id" {
  description = "The ID/name of the EKS cluster"
  value       = try(aws_eks_cluster.main[0].id, null)
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = try(aws_eks_cluster.main[0].arn, null)
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = try(aws_eks_cluster.main[0].name, null)
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = try(aws_eks_cluster.main[0].endpoint, null)
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = try(aws_eks_cluster.main[0].version, null)
}

output "cluster_platform_version" {
  description = "The platform version for the cluster"
  value       = try(aws_eks_cluster.main[0].platform_version, null)
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = try(aws_eks_cluster.main[0].status, null)
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = try(aws_eks_cluster.main[0].certificate_authority[0].data, null)
  sensitive   = true
}

# =============================================================================
# Cluster Security Group Outputs
# =============================================================================
output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster control plane"
  value       = try(aws_eks_cluster.main[0].vpc_config[0].cluster_security_group_id, null)
}

output "cluster_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the cluster security group"
  value = try(
    "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:security-group/${aws_eks_cluster.main[0].vpc_config[0].cluster_security_group_id}",
    null
  )
}

# =============================================================================
# OIDC Provider Outputs
# =============================================================================
output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = try(aws_eks_cluster.main[0].identity[0].oidc[0].issuer, null)
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for EKS (useful for IRSA)"
  value       = local.oidc_provider_arn
}

# =============================================================================
# IAM Role Outputs
# =============================================================================
output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = local.cluster_role_arn
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster"
  value       = try(aws_iam_role.cluster[0].name, null)
}

output "node_iam_role_arn" {
  description = "IAM role ARN of the EKS nodes"
  value       = local.node_role_arn
}

output "node_iam_role_name" {
  description = "IAM role name of the EKS nodes"
  value       = try(aws_iam_role.node[0].name, null)
}

output "fargate_iam_role_arn" {
  description = "IAM role ARN for Fargate pod execution"
  value       = try(aws_iam_role.fargate_pod_execution[0].arn, null)
}

output "fargate_iam_role_name" {
  description = "IAM role name for Fargate pod execution"
  value       = try(aws_iam_role.fargate_pod_execution[0].name, null)
}

# =============================================================================
# Node Group Outputs
# =============================================================================
output "node_groups" {
  description = "Map of attribute maps for all EKS node groups created"
  value = {
    for k, v in aws_eks_node_group.this : k => {
      id               = v.id
      arn              = v.arn
      status           = v.status
      capacity_type    = v.capacity_type
      instance_types   = v.instance_types
      labels           = v.labels
      resources        = v.resources
      scaling_config   = v.scaling_config
      taints           = v.taint
      version          = v.version
    }
  }
}

output "node_group_ids" {
  description = "Map of node group names to IDs"
  value       = { for k, v in aws_eks_node_group.this : k => v.id }
}

output "node_group_arns" {
  description = "Map of node group names to ARNs"
  value       = { for k, v in aws_eks_node_group.this : k => v.arn }
}

output "node_group_statuses" {
  description = "Map of node group names to status"
  value       = { for k, v in aws_eks_node_group.this : k => v.status }
}

# =============================================================================
# Launch Template Outputs
# =============================================================================
output "launch_template_id" {
  description = "ID of the launch template"
  value       = try(aws_launch_template.eks_workers[0].id, null)
}

output "launch_template_arn" {
  description = "ARN of the launch template"
  value       = try(aws_launch_template.eks_workers[0].arn, null)
}

output "launch_template_name" {
  description = "Name of the launch template"
  value       = try(aws_launch_template.eks_workers[0].name, null)
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = try(aws_launch_template.eks_workers[0].latest_version, null)
}

output "launch_template_default_version" {
  description = "Default version of the launch template"
  value       = try(aws_launch_template.eks_workers[0].default_version, null)
}

# =============================================================================
# Add-ons Outputs
# =============================================================================
output "cluster_addons" {
  description = "Map of attribute maps for all EKS cluster addons"
  value = {
    for k, v in aws_eks_addon.this : k => {
      id                = v.id
      arn               = v.arn
      addon_name        = v.addon_name
      addon_version     = v.addon_version
      created_at        = v.created_at
      modified_at       = v.modified_at
      service_account_role_arn = v.service_account_role_arn
    }
  }
}

output "addon_versions" {
  description = "Map of add-on names to installed versions"
  value       = { for k, v in aws_eks_addon.this : k => v.addon_version }
}

# =============================================================================
# Fargate Profile Outputs
# =============================================================================
output "fargate_profiles" {
  description = "Map of attribute maps for all EKS Fargate profiles"
  value = {
    for k, v in aws_eks_fargate_profile.this : k => {
      id                     = v.id
      arn                    = v.arn
      status                 = v.status
      pod_execution_role_arn = v.pod_execution_role_arn
    }
  }
}

output "fargate_profile_ids" {
  description = "Map of Fargate profile names to IDs"
  value       = { for k, v in aws_eks_fargate_profile.this : k => v.id }
}

output "fargate_profile_arns" {
  description = "Map of Fargate profile names to ARNs"
  value       = { for k, v in aws_eks_fargate_profile.this : k => v.arn }
}

# =============================================================================
# Access Entry Outputs
# =============================================================================
output "access_entries" {
  description = "Map of access entries created"
  value = {
    for k, v in aws_eks_access_entry.this : k => {
      principal_arn = v.principal_arn
      type          = v.type
      user_name     = v.user_name
      access_entry_arn = v.access_entry_arn
      created_at    = v.created_at
      modified_at   = v.modified_at
    }
  }
}

# =============================================================================
# Pod Identity Outputs
# =============================================================================
output "pod_identity_associations" {
  description = "Map of Pod Identity associations"
  value = {
    for k, v in aws_eks_pod_identity_association.this : k => {
      association_arn = v.association_arn
      association_id  = v.association_id
      namespace       = v.namespace
      service_account = v.service_account
    }
  }
}

# =============================================================================
# Kubectl Configuration Output
# =============================================================================
output "cluster_auth_token" {
  description = "Auth token for kubectl configuration (expires in 15 minutes)"
  value       = try(data.aws_eks_cluster_auth.cluster[0].token, null)
  sensitive   = true
}

output "kubeconfig_command" {
  description = "Command to update local kubeconfig"
  value       = var.create_cluster ? "aws eks update-kubeconfig --region ${data.aws_region.current.id} --name ${aws_eks_cluster.main[0].name}" : null
}
