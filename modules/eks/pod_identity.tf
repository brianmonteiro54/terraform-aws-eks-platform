# =============================================================================
# EKS Pod Identity Associations
# =============================================================================
resource "aws_eks_pod_identity_association" "this" {
  for_each = var.pod_identity_associations

  cluster_name    = aws_eks_cluster.main.name
  namespace       = each.value.namespace
  service_account = each.value.service_account
  role_arn        = each.value.role_arn

  tags = merge(
    var.tags,
    var.cluster_tags,
    try(each.value.tags, {})
  )

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_addon.this
  ]
}
