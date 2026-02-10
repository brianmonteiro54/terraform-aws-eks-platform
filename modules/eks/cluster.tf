# =============================================================================
# EKS Cluster
# =============================================================================
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = var.cluster_subnet_ids

    # Se vazio, omite o argumento (evita enviar [] pro API)
    security_group_ids = length(var.cluster_security_group_ids) > 0 ? var.cluster_security_group_ids : null

    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
    ip_family         = var.ip_family
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
  }

  upgrade_policy {
    support_type = var.support_type
  }

  dynamic "encryption_config" {
    for_each = var.cluster_encryption_config == null ? [] : [var.cluster_encryption_config]
    content {
      provider {
        key_arn = encryption_config.value.provider_key_arn
      }
      resources = encryption_config.value.resources
    }
  }

  deletion_protection = var.deletion_protection

  tags = merge(var.tags, var.cluster_tags)
}
