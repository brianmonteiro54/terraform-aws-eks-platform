# =============================================================================
# EKS Pod Identity Associations
# =============================================================================
resource "aws_eks_pod_identity_association" "this" {
  for_each = var.create_cluster ? var.pod_identity_associations : {}

  cluster_name    = aws_eks_cluster.main[0].name
  namespace       = each.value.namespace
  service_account = each.value.service_account
  role_arn        = each.value.role_arn

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
