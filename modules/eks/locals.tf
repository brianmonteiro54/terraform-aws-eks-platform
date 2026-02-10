# =============================================================================
# Locals
# =============================================================================
locals {
  nodegroup_az_index = {
    for name, _ in var.nodegroups :
    name => lookup(var.nodegroup_az_mapping, name, null)
  }

  nodegroup_subnets = {
    for name, idx in local.nodegroup_az_index :
    name => (
      idx == null
      ? var.nodegroup_subnet_ids
      : [var.nodegroup_subnet_ids[idx]]
    )
  }
}
