# =============================================================================
# Local Values
# =============================================================================

locals {
  # Cluster identification
  cluster_name = var.cluster_name

  # Common tags merged with custom tags
  common_tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${local.cluster_name}" = "owned"
      ManagedBy                                      = "Terraform"
      ClusterName                                    = local.cluster_name
    }
  )

  # OIDC provider configuration
  oidc_provider_arn = var.create_cluster ? try(
    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.main[0].identity[0].oidc[0].issuer, "https://", "")}",
    null
  ) : null

  # Node group subnet mapping
  nodegroup_az_index = {
    for name, _ in var.nodegroups :
    name => lookup(var.nodegroup_az_mapping, name, null)
  }

  nodegroup_subnets = {
    for name, idx in local.nodegroup_az_index :
    name => (
      idx == null
      ? var.nodegroup_subnet_ids
      : [var.nodegroup_subnet_ids[idx]]
    )
  }

  # Launch template defaults
  launch_template_enabled = var.create_launch_template && var.create_cluster
  
  # Metadata options with secure defaults
  metadata_options = merge(
    {
      http_endpoint               = "enabled"
      http_tokens                 = "required"  # IMDSv2 required for security
      http_put_response_hop_limit = 2
      instance_metadata_tags      = "enabled"
    },
    var.launch_template_metadata_options
  )

  # EBS configuration with intelligent defaults
  launch_template_volume_type = coalesce(
    var.launch_template_volume_type,
    var.launch_template_volume_iops != null ? "gp3" : "gp3"
  )

  # Calculate IOPS based on volume size if not specified
  launch_template_volume_iops = coalesce(
    var.launch_template_volume_iops,
    local.launch_template_volume_type == "gp3" ? min(max(3000, var.launch_template_volume_size * 3), 16000) : null,
    local.launch_template_volume_type == "io1" || local.launch_template_volume_type == "io2" ? 3000 : null
  )

  # Cluster logging types
  enabled_cluster_log_types = var.cluster_logging_enabled ? var.enabled_cluster_log_types : []

  # IAM role ARNs - use provided or created
  # For AWS Academy: create_iam_roles = false, must provide cluster_role_arn and node_role_arn
  cluster_role_arn = var.create_iam_roles ? try(aws_iam_role.cluster[0].arn, null) : var.cluster_role_arn
  node_role_arn    = var.create_iam_roles ? try(aws_iam_role.node[0].arn, null) : var.node_role_arn
}
