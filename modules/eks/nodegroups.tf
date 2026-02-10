# =============================================================================
# EKS Managed Node Groups
# =============================================================================
resource "aws_eks_node_group" "this" {
  for_each = var.create_cluster && var.create_node_groups ? var.nodegroups : {}

  cluster_name    = aws_eks_cluster.main[0].name
  node_group_name = each.key
  node_role_arn   = local.node_role_arn
  subnet_ids      = local.nodegroup_subnets[each.key]

  # AMI configuration
  ami_type       = each.value.ami_type
  capacity_type  = each.value.capacity_type
  disk_size      = each.value.disk_size

  # Instance configuration
  instance_types = length(try(each.value.instance_types, [])) > 0 ? each.value.instance_types : null

  # Kubernetes version
  version         = coalesce(each.value.version, var.cluster_version)
  release_version = each.value.release_version

  # Node labels
  labels = merge(
    {
      "node.kubernetes.io/nodegroup" = each.key
    },
    try(each.value.labels, {})
  )

  # Taints
  dynamic "taint" {
    for_each = try(each.value.taints, [])
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
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

  # Scaling configuration
  scaling_config {
    min_size     = each.value.scaling_min
    max_size     = each.value.scaling_max
    desired_size = each.value.scaling_desired
  }

  # Update configuration
update_config {
    max_unavailable = coalesce(each.value.max_unavailable, var.nodegroup_max_unavailable)
  }

  # Launch template
  dynamic "launch_template" {
    for_each = local.launch_template_enabled ? [1] : []
    content {
      id      = aws_launch_template.eks_workers[0].id
      version = aws_launch_template.eks_workers[0].latest_version
    }
  }

  # Remote access configuration (optional)
  dynamic "remote_access" {
    for_each = each.value.remote_access_enabled ? [1] : []
    content {
      ec2_ssh_key               = each.value.ec2_ssh_key
      source_security_group_ids = each.value.source_security_group_ids
    }
  }

  # Lifecycle management
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }

  # Timeouts
  timeouts {
    create = var.nodegroup_timeouts.create
    update = var.nodegroup_timeouts.update
    delete = var.nodegroup_timeouts.delete
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_launch_template.eks_workers,
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_registry_policy
  ]
}