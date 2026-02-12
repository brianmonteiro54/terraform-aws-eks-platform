# =============================================================================
# EKS Fargate Profiles
# =============================================================================
resource "aws_eks_fargate_profile" "this" {
  for_each = var.create_cluster ? var.fargate_profiles : {}

  cluster_name           = aws_eks_cluster.main[0].name
  fargate_profile_name   = each.key
  pod_execution_role_arn = var.create_iam_roles ? try(aws_iam_role.fargate_pod_execution[0].arn, null) : var.node_role_arn
  subnet_ids             = each.value.subnet_ids

  # Pod selectors
  dynamic "selector" {
    for_each = each.value.selectors
    content {
      namespace = selector.value.namespace
      labels    = try(selector.value.labels, {})
    }
  }

  # Tags
  tags = merge(
    local.common_tags,
    var.cluster_tags,
    {
      Name = "${var.cluster_name}-${each.key}"
    },
    try(each.value.tags, {})
  )

  # Timeouts
  timeouts {
    create = try(each.value.timeouts.create, "10m")
    delete = try(each.value.timeouts.delete, "10m")
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_iam_role_policy_attachment.fargate_pod_execution_policy
  ]
}
