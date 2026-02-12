# =============================================================================
# EKS Add-ons
# =============================================================================
resource "aws_eks_addon" "this" {
  for_each = var.create_cluster ? var.addons : {}

  cluster_name  = aws_eks_cluster.main[0].name
  addon_name    = each.key
  addon_version = each.value.addon_version

  # Configuration values (JSON string)
  configuration_values = try(each.value.configuration_values, null)

  # Conflict resolution strategy
  resolve_conflicts_on_create = coalesce(
    try(each.value.resolve_conflicts_on_create, null),
    try(each.value.resolve_conflicts, null),
    "OVERWRITE"
  )

  resolve_conflicts_on_update = coalesce(
    try(each.value.resolve_conflicts_on_update, null),
    try(each.value.resolve_conflicts, null),
    "OVERWRITE"
  )

  # Preserve settings when deleting addon
  preserve = try(each.value.preserve, false)

  # Service account IAM role for IRSA
  service_account_role_arn = try(each.value.service_account_role_arn, null)

  # Tags
  tags = merge(
    local.common_tags,
    var.cluster_tags,
    {
      Name      = "${var.cluster_name}-${each.key}"
      AddonName = each.key
    },
    try(each.value.tags, {})
  )

  # Timeouts
  timeouts {
    create = try(each.value.timeouts.create, "20m")
    update = try(each.value.timeouts.update, "20m")
    delete = try(each.value.timeouts.delete, "40m")
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.this
  ]
}
