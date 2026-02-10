# =============================================================================
# EKS Cluster
# =============================================================================
resource "aws_eks_cluster" "main" {
  count = var.create_cluster ? 1 : 0

  name     = var.cluster_name
  role_arn = local.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = var.cluster_subnet_ids

    # Only set security_group_ids if provided (empty list causes API errors)
    security_group_ids = length(var.cluster_security_group_ids) > 0 ? var.cluster_security_group_ids : null

    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    
    # Optional: restrict public access to specific CIDRs
    public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
    ip_family         = var.ip_family
  }

  enabled_cluster_log_types = local.enabled_cluster_log_types

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
  }

  upgrade_policy {
    support_type = var.support_type
  }

  # Optional: KMS encryption for secrets
  dynamic "encryption_config" {
    for_each = var.cluster_encryption_config != null ? [var.cluster_encryption_config] : []
    content {
      provider {
        key_arn = encryption_config.value.provider_key_arn
      }
      resources = encryption_config.value.resources
    }
  }

  # Deletion protection for production clusters
  deletion_protection = var.deletion_protection

  tags = merge(
    local.common_tags,
    var.cluster_tags,
    {
      Name = var.cluster_name
    }
  )

  depends_on = var.create_iam_roles ? [
    aws_iam_role_policy_attachment.cluster_policy[0],
    aws_iam_role_policy_attachment.cluster_service_policy[0],
  ] : []

  timeouts {
    create = var.cluster_timeouts.create
    update = var.cluster_timeouts.update
    delete = var.cluster_timeouts.delete
  }
}

# =============================================================================
# Cluster Security Group Rules
# =============================================================================
resource "aws_security_group_rule" "cluster_ingress_workstation_https" {
  count = var.create_cluster && length(var.cluster_security_group_additional_rules) > 0 ? length(var.cluster_security_group_additional_rules) : 0

  security_group_id = aws_eks_cluster.main[0].vpc_config[0].cluster_security_group_id
  description       = var.cluster_security_group_additional_rules[count.index].description
  type              = var.cluster_security_group_additional_rules[count.index].type
  from_port         = var.cluster_security_group_additional_rules[count.index].from_port
  to_port           = var.cluster_security_group_additional_rules[count.index].to_port
  protocol          = var.cluster_security_group_additional_rules[count.index].protocol
  cidr_blocks       = var.cluster_security_group_additional_rules[count.index].cidr_blocks
}
