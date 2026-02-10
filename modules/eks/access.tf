# =============================================================================
# EKS Access Entries
# =============================================================================
resource "aws_eks_access_entry" "this" {
  for_each = var.access_entries

  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = each.value.principal_arn
  kubernetes_groups = try(each.value.kubernetes_groups, [])
  type              = each.value.type
  user_name         = try(each.value.user_name, null)

  tags = merge(
    var.tags,
    var.cluster_tags,
    try(each.value.tags, {})
  )

  depends_on = [
    aws_eks_cluster.main
  ]
}

locals {
  policy_associations = flatten([
    for entry_key, entry_val in var.access_entries : [
      for idx, policy in try(entry_val.policy_associations, []) : {
        entry_key     = entry_key
        policy_key    = "${entry_key}_${idx}"
        principal_arn = entry_val.principal_arn
        policy_arn    = policy.policy_arn
        access_scope  = policy.access_scope
      }
    ]
  ])

  policy_associations_map = {
    for assoc in local.policy_associations :
    assoc.policy_key => assoc
  }
}

resource "aws_eks_access_policy_association" "this" {
  for_each = local.policy_associations_map

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.access_scope.type
    namespaces = try(each.value.access_scope.namespaces, [])
  }

  depends_on = [
    aws_eks_access_entry.this
  ]
}
