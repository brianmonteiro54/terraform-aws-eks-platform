# =============================================================================
# EKS Addons
# =============================================================================
resource "aws_eks_addon" "this" {
  for_each = var.addons

  cluster_name         = aws_eks_cluster.main.name
  addon_name           = each.key
  addon_version        = each.value.addon_version
  configuration_values = try(each.value.configuration_values, null)

  # compatível com seu tfvars atual (resolve_conflicts)
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

  service_account_role_arn = try(each.value.service_account_role_arn, null)

  tags = merge(
    var.tags,
    var.cluster_tags,
    try(each.value.tags, {})
  )

  depends_on = [
    aws_eks_cluster.main
  ]
}
