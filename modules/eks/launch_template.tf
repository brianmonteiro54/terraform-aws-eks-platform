# =============================================================================
# Launch Template for EKS Worker Nodes
# =============================================================================
resource "aws_launch_template" "eks_workers" {
  name                   = var.launch_template_name
  description            = var.launch_template_name
  update_default_version = var.launch_template_update_default_version

  instance_type          = var.launch_template_instance_type
  vpc_security_group_ids = var.worker_security_group_ids
  ebs_optimized          = var.launch_template_ebs_optimized

  block_device_mappings {
    device_name = var.launch_template_device_name

    ebs {
      volume_size           = var.launch_template_volume_size
      volume_type           = var.launch_template_volume_type
      iops                  = var.launch_template_volume_iops
      delete_on_termination = var.launch_template_delete_on_termination
      encrypted             = var.launch_template_encrypted
    }
  }

  metadata_options {
    http_endpoint               = var.launch_template_metadata.http_endpoint
    http_tokens                 = var.launch_template_metadata.http_tokens
    http_put_response_hop_limit = var.launch_template_metadata.http_put_response_hop_limit
    instance_metadata_tags      = var.launch_template_metadata.instance_metadata_tags
  }

  dynamic "tag_specifications" {
    for_each = var.launch_template_tag_resource_types
    content {
      resource_type = tag_specifications.value
      tags = merge(
        var.tags,
        var.cluster_tags,
        { Name = var.launch_template_worker_tag }
      )
    }
  }

  tags = merge(var.tags, var.cluster_tags, {
    Name = var.launch_template_name
  })
}
