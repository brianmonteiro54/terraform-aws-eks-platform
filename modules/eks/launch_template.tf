# =============================================================================
# Launch Template for EKS Worker Nodes
# =============================================================================
resource "aws_launch_template" "eks_workers" {
  count = local.launch_template_enabled ? 1 : 0

  name                   = coalesce(var.launch_template_name, "${var.cluster_name}-node-template")
  description            = coalesce(var.launch_template_description, "Launch template for ${var.cluster_name} EKS nodes")
  update_default_version = var.launch_template_update_default_version

  # Instance configuration
  instance_type          = var.launch_template_instance_type
  vpc_security_group_ids = var.worker_security_group_ids
  ebs_optimized          = var.launch_template_ebs_optimized
  
  # User data for EKS bootstrap (optional)
  user_data = var.launch_template_user_data_base64 != null ? var.launch_template_user_data_base64 : null

  # EBS volume configuration
  block_device_mappings {
    device_name = var.launch_template_device_name

    ebs {
      volume_size           = var.launch_template_volume_size
      volume_type           = local.launch_template_volume_type
      iops                  = local.launch_template_volume_iops
      throughput            = var.launch_template_volume_throughput
      delete_on_termination = var.launch_template_delete_on_termination
      encrypted             = var.launch_template_encrypted
      kms_key_id            = var.launch_template_kms_key_id
    }
  }

  # Instance metadata configuration (IMDSv2)
  metadata_options {
    http_endpoint               = local.metadata_options.http_endpoint
    http_tokens                 = local.metadata_options.http_tokens
    http_put_response_hop_limit = local.metadata_options.http_put_response_hop_limit
    instance_metadata_tags      = local.metadata_options.instance_metadata_tags
  }

  # Monitoring
  monitoring {
    enabled = var.launch_template_enable_monitoring
  }

  # Network interfaces configuration
  dynamic "network_interfaces" {
    for_each = var.launch_template_network_interfaces
    content {
      associate_public_ip_address = network_interfaces.value.associate_public_ip_address
      delete_on_termination       = network_interfaces.value.delete_on_termination
      description                 = network_interfaces.value.description
      device_index                = network_interfaces.value.device_index
      security_groups             = network_interfaces.value.security_groups
    }
  }

  # Tag specifications for instances and volumes
  dynamic "tag_specifications" {
    for_each = var.launch_template_tag_resource_types
    content {
      resource_type = tag_specifications.value
      tags = merge(
        local.common_tags,
        var.cluster_tags,
        {
          Name = coalesce(
            var.launch_template_worker_tag,
            "${var.cluster_name}-node"
          )
        },
        var.launch_template_additional_tags
      )
    }
  }

  tags = merge(
    local.common_tags,
    var.cluster_tags,
    {
      Name = coalesce(var.launch_template_name, "${var.cluster_name}-node-template")
    },
    var.launch_template_additional_tags
  )
}
