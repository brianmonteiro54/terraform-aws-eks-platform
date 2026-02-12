# =============================================================================
# EKS Cluster Access Entries
# =============================================================================
resource "aws_eks_access_entry" "this" {
  for_each = var.create_cluster ? var.access_entries : {}

  cluster_name  = aws_eks_cluster.main[0].name
  principal_arn = each.value.principal_arn
  type          = each.value.type

  # Kubernetes groups (for EC2 access entries)
  kubernetes_groups = try(each.value.kubernetes_groups, [])

  # Username (optional, for display purposes)
  user_name = try(each.value.user_name, null)

  # Tags
  tags = merge(
    local.common_tags,
    var.cluster_tags,
    {
      Name = "${var.cluster_name}-${each.key}"
    },
    try(each.value.tags, {})
  )

  depends_on = [
    aws_eks_cluster.main
  ]
}

# =============================================================================
# EKS Cluster Access Policy Associations
# =============================================================================
resource "aws_eks_access_policy_association" "this" {
  for_each = merge([
    for entry_name, entry in var.access_entries : {
      for idx, policy in try(entry.policy_associations, []) :
      "${entry_name}-${idx}" => {
        entry_name   = entry_name
        policy_arn   = policy.policy_arn
        access_scope = policy.access_scope
      }
    }
  ]...)

  cluster_name  = aws_eks_cluster.main[0].name
  principal_arn = var.access_entries[each.value.entry_name].principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.access_scope.type
    namespaces = try(each.value.access_scope.namespaces, [])
  }

  depends_on = [
    aws_eks_access_entry.this
  ]
}
