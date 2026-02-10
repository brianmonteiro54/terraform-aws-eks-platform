# =============================================================================
# EKS Node Groups
# =============================================================================
resource "aws_eks_node_group" "this" {
  for_each = var.nodegroups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn   = var.node_role_arn
  subnet_ids      = local.nodegroup_subnets[each.key]

  ami_type       = each.value.ami_type
  capacity_type  = each.value.capacity_type

  # Se vier vazio, manda null (assim LT assume o instance_type)
  instance_types = length(try(each.value.instance_types, [])) > 0 ? each.value.instance_types : null

  version         = try(each.value.version, null)
  release_version = try(each.value.release_version, null)

  labels = try(each.value.labels, {})

  # Best practice: sempre herdando tags base (var.tags + var.cluster_tags)
  tags = merge(
    var.tags,
    var.cluster_tags,
    try(each.value.tags, {})
  )

  scaling_config {
    min_size     = each.value.scaling_min
    max_size     = each.value.scaling_max
    desired_size = each.value.scaling_desired
  }

  update_config {
    max_unavailable = var.nodegroup_max_unavailable
  }

  launch_template {
    id      = aws_launch_template.eks_workers.id
    version = aws_launch_template.eks_workers.latest_version
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  timeouts {
    create = var.nodegroup_timeouts.create
    update = var.nodegroup_timeouts.update
    delete = var.nodegroup_timeouts.delete
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_launch_template.eks_workers
  ]
}
