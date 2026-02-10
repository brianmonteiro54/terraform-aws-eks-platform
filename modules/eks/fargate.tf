# =============================================================================
# EKS Fargate Profiles
# =============================================================================
resource "aws_eks_fargate_profile" "this" {
  for_each = var.fargate_profiles

  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = each.key
  pod_execution_role_arn = each.value.pod_execution_role_arn
  subnet_ids             = each.value.subnet_ids

  dynamic "selector" {
    for_each = each.value.selectors
    content {
      namespace = selector.value.namespace
      labels    = try(selector.value.labels, {})
    }
  }

  tags = merge(
    var.tags,
    var.cluster_tags,
    try(each.value.tags, {})
  )

  depends_on = [
    aws_eks_cluster.main
  ]
}
