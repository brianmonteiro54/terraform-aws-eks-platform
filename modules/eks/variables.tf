# =============================================================================
# Required Variables
# =============================================================================
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string

  validation {
    condition     = length(var.cluster_name) <= 100 && can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.cluster_name))
    error_message = "Cluster name must start with a letter, be up to 100 characters, and contain only alphanumeric characters and hyphens."
  }
}

# =============================================================================
# Module Control Variables
# =============================================================================
variable "create_cluster" {
  description = "Controls if EKS cluster should be created (affects all resources)"
  type        = bool
  default     = true
}

variable "create_iam_roles" {
  description = "Create IAM roles for cluster and nodes. If false, must provide cluster_role_arn and node_role_arn. Set to false for AWS Academy environments."
  type        = bool
  default     = false  # Changed to false for AWS Academy compatibility
}

variable "create_launch_template" {
  description = "Create launch template for node groups"
  type        = bool
  default     = true
}

variable "create_node_groups" {
  description = "Create managed node groups"
  type        = bool
  default     = true
}

# =============================================================================
# Cluster Configuration
# =============================================================================
variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.31"

  validation {
    condition     = can(regex("^1\\.(2[7-9]|3[0-9])$", var.cluster_version))
    error_message = "EKS cluster version must be 1.27 or higher."
  }
}

variable "cluster_role_arn" {
  description = "IAM Role ARN for the EKS cluster control plane (required if create_iam_roles is false). For AWS Academy, use LabRole ARN."
  type        = string
  default     = null

  validation {
    condition     = var.create_iam_roles || (var.cluster_role_arn != null && var.cluster_role_arn != "")
    error_message = "cluster_role_arn must be provided when create_iam_roles is false. For AWS Academy, use data source to get LabRole ARN."
  }
}

variable "cluster_subnet_ids" {
  description = "List of subnet IDs for the EKS cluster control plane (recommended: private subnets in multiple AZs)"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.cluster_subnet_ids) >= 2 || !var.create_cluster
    error_message = "At least 2 subnets required for cluster high availability."
  }
}

variable "cluster_security_group_ids" {
  description = "Additional security group IDs to attach to the cluster control plane ENIs"
  type        = list(string)
  default     = []
}

variable "cluster_security_group_additional_rules" {
  description = "Additional security group rules to add to the cluster security group"
  type = list(object({
    description = string
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

# =============================================================================
# Network Configuration
# =============================================================================
variable "endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "service_ipv4_cidr" {
  description = "CIDR block for Kubernetes services (must not overlap with VPC CIDR)"
  type        = string
  default     = "172.20.0.0/16"

  validation {
    condition     = can(cidrhost(var.service_ipv4_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

variable "ip_family" {
  description = "IP family for Kubernetes networking (ipv4 or ipv6)"
  type        = string
  default     = "ipv4"

  validation {
    condition     = contains(["ipv4", "ipv6"], var.ip_family)
    error_message = "IP family must be 'ipv4' or 'ipv6'."
  }
}

# =============================================================================
# Logging Configuration
# =============================================================================
variable "cluster_logging_enabled" {
  description = "Enable cluster control plane logging"
  type        = bool
  default     = true
}

variable "enabled_cluster_log_types" {
  description = "List of control plane logging types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  validation {
    condition = alltrue([
      for log_type in var.enabled_cluster_log_types :
      contains(["api", "audit", "authenticator", "controllerManager", "scheduler"], log_type)
    ])
    error_message = "Valid log types are: api, audit, authenticator, controllerManager, scheduler."
  }
}

# =============================================================================
# Authentication & Access
# =============================================================================
variable "authentication_mode" {
  description = "Authentication mode for the cluster (CONFIG_MAP, API, or API_AND_CONFIG_MAP)"
  type        = string
  default     = "API_AND_CONFIG_MAP"

  validation {
    condition     = contains(["CONFIG_MAP", "API", "API_AND_CONFIG_MAP"], var.authentication_mode)
    error_message = "authentication_mode must be CONFIG_MAP, API, or API_AND_CONFIG_MAP."
  }
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Grant cluster creator admin permissions automatically"
  type        = bool
  default     = true
}

# =============================================================================
# Cluster Features
# =============================================================================
variable "support_type" {
  description = "EKS support type (STANDARD or EXTENDED)"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "EXTENDED"], var.support_type)
    error_message = "support_type must be 'STANDARD' or 'EXTENDED'."
  }
}

variable "deletion_protection" {
  description = "Enable deletion protection for the cluster"
  type        = bool
  default     = false
}

variable "cluster_encryption_config" {
  description = "Configuration for envelope encryption of Kubernetes secrets using KMS"
  type = object({
    provider_key_arn = string
    resources        = list(string)
  })
  default = null
}

# =============================================================================
# Timeouts
# =============================================================================
variable "cluster_timeouts" {
  description = "Timeout configuration for cluster operations"
  type = object({
    create = string
    update = string
    delete = string
  })
  default = {
    create = "30m"
    update = "60m"
    delete = "15m"
  }
}

# =============================================================================
# IAM Configuration
# =============================================================================
variable "node_role_arn" {
  description = "IAM Role ARN for EKS node groups (required if create_iam_roles is false). For AWS Academy, use LabRole ARN."
  type        = string
  default     = null

  validation {
    condition     = var.create_iam_roles || (var.node_role_arn != null && var.node_role_arn != "")
    error_message = "node_role_arn must be provided when create_iam_roles is false. For AWS Academy, use data source to get LabRole ARN."
  }
}

variable "enable_ssm_access" {
  description = "Enable AWS Systems Manager access for node groups"
  type        = bool
  default     = true
}

# =============================================================================
# Launch Template Configuration
# =============================================================================
variable "launch_template_name" {
  description = "Name of the launch template (defaults to cluster-name-node-template)"
  type        = string
  default     = null
}

variable "launch_template_description" {
  description = "Description of the launch template"
  type        = string
  default     = null
}

variable "launch_template_instance_type" {
  description = "Default instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "launch_template_update_default_version" {
  description = "Whether to update default version on each launch template update"
  type        = bool
  default     = true
}

variable "worker_security_group_ids" {
  description = "Security group IDs for worker nodes"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.worker_security_group_ids) > 0 || !var.create_launch_template || !var.create_cluster
    error_message = "At least one security group required for worker nodes when creating launch template."
  }
}

# EBS Volume Configuration
variable "launch_template_volume_size" {
  description = "Size of the EBS volume in GB"
  type        = number
  default     = 50

  validation {
    condition     = var.launch_template_volume_size >= 20 && var.launch_template_volume_size <= 16384
    error_message = "Volume size must be between 20 GB and 16384 GB."
  }
}

variable "launch_template_volume_type" {
  description = "Type of EBS volume (gp3, gp2, io1, io2)"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.launch_template_volume_type)
    error_message = "Volume type must be one of: gp2, gp3, io1, io2."
  }
}

variable "launch_template_volume_iops" {
  description = "IOPS for the EBS volume (only for gp3, io1, io2). Leave null for auto-calculation"
  type        = number
  default     = null

  validation {
    condition = (
      var.launch_template_volume_iops == null ||
      (var.launch_template_volume_iops >= 3000 && var.launch_template_volume_iops <= 16000)
    )
    error_message = "IOPS must be between 3000 and 16000 when specified."
  }
}

variable "launch_template_volume_throughput" {
  description = "Throughput in MB/s for gp3 volumes"
  type        = number
  default     = 125

  validation {
    condition     = var.launch_template_volume_throughput >= 125 && var.launch_template_volume_throughput <= 1000
    error_message = "Throughput must be between 125 and 1000 MB/s."
  }
}

variable "launch_template_device_name" {
  description = "Device name for the root EBS volume"
  type        = string
  default     = "/dev/xvda"
}

variable "launch_template_delete_on_termination" {
  description = "Whether to delete EBS volume on instance termination"
  type        = bool
  default     = true
}

variable "launch_template_encrypted" {
  description = "Enable EBS volume encryption"
  type        = bool
  default     = true
}

variable "launch_template_kms_key_id" {
  description = "KMS key ID for EBS encryption (uses AWS managed key if not specified)"
  type        = string
  default     = null
}

variable "launch_template_ebs_optimized" {
  description = "Enable EBS optimization"
  type        = bool
  default     = true
}

variable "launch_template_enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

# Metadata Options (IMDSv2)
variable "launch_template_metadata_options" {
  description = "Instance metadata service configuration"
  type = object({
    http_endpoint               = string
    http_tokens                 = string
    http_put_response_hop_limit = number
    instance_metadata_tags      = string
  })
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2 required
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }
}

# User Data
variable "launch_template_user_data_base64" {
  description = "Base64-encoded user data for bootstrapping nodes"
  type        = string
  default     = null
  sensitive   = true
}

# Network Interfaces
variable "launch_template_network_interfaces" {
  description = "Network interface configuration for launch template"
  type = list(object({
    associate_public_ip_address = bool
    delete_on_termination       = bool
    description                 = string
    device_index                = number
    security_groups             = list(string)
  }))
  default = []
}

# Tags
variable "launch_template_worker_tag" {
  description = "Name tag for worker instances (defaults to cluster-name-node)"
  type        = string
  default     = null
}

variable "launch_template_tag_resource_types" {
  description = "Resource types to tag (instance, volume, network-interface)"
  type        = list(string)
  default     = ["instance", "volume"]
}

variable "launch_template_additional_tags" {
  description = "Additional tags for launch template and resources"
  type        = map(string)
  default     = {}
}

# =============================================================================
# Node Groups Configuration
# =============================================================================
variable "nodegroups" {
  description = "Map of EKS managed node groups to create"
  type = map(object({
    scaling_min                = number
    scaling_max                = number
    scaling_desired            = number
    ami_type                   = optional(string, "AL2_x86_64")
    capacity_type              = optional(string, "ON_DEMAND")
    disk_size                  = optional(number, null)
    instance_types             = optional(list(string), [])
    version                    = optional(string, null)
    release_version            = optional(string, null)
    labels                     = optional(map(string), {})
    taints                     = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    max_unavailable            = optional(number, null)
    max_unavailable_percentage = optional(number, null)
    remote_access_enabled      = optional(bool, false)
    ec2_ssh_key                = optional(string, null)
    source_security_group_ids  = optional(list(string), [])
    tags                       = optional(map(string), {})
  }))
  default = {}
}

variable "nodegroup_subnet_ids" {
  description = "Subnet IDs for node groups (typically private subnets)"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.nodegroup_subnet_ids) >= 1 || !var.create_node_groups || !var.create_cluster
    error_message = "At least 1 subnet required for node groups."
  }
}

variable "nodegroup_az_mapping" {
  description = "Map nodegroup name to specific subnet index for AZ pinning"
  type        = map(number)
  default     = {}
}

variable "nodegroup_max_unavailable" {
  description = "Default max unavailable nodes during updates"
  type        = number
  default     = 1

  validation {
    condition     = var.nodegroup_max_unavailable >= 1
    error_message = "max_unavailable must be at least 1."
  }
}

variable "nodegroup_timeouts" {
  description = "Timeout configuration for node group operations"
  type = object({
    create = string
    update = string
    delete = string
  })
  default = {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}

# =============================================================================
# EKS Add-ons Configuration
# =============================================================================
variable "addons" {
  description = "Map of EKS add-ons to install"
  type = map(object({
    addon_version                = string
    configuration_values          = optional(string, null)
    resolve_conflicts             = optional(string, "OVERWRITE")
    resolve_conflicts_on_create   = optional(string, null)
    resolve_conflicts_on_update   = optional(string, null)
    preserve                      = optional(bool, false)
    service_account_role_arn      = optional(string, null)
    tags                          = optional(map(string), {})
    timeouts                      = optional(object({
      create = string
      update = string
      delete = string
    }), {
      create = "20m"
      update = "20m"
      delete = "40m"
    })
  }))
  default = {}
}

# =============================================================================
# Fargate Profiles Configuration
# =============================================================================
variable "fargate_profiles" {
  description = "Map of Fargate profiles to create"
  type = map(object({
    pod_execution_role_arn = optional(string, null)
    subnet_ids             = list(string)
    selectors = list(object({
      namespace = string
      labels    = optional(map(string), {})
    }))
    tags = optional(map(string), {})
    timeouts = optional(object({
      create = string
      delete = string
    }), {
      create = "10m"
      delete = "10m"
    })
  }))
  default = {}
}

# =============================================================================
# Access Entries Configuration
# =============================================================================
variable "access_entries" {
  description = "Map of IAM principals to grant cluster access"
  type = map(object({
    principal_arn     = string
    kubernetes_groups = optional(list(string), [])
    type              = string
    user_name         = optional(string, null)
    policy_associations = optional(list(object({
      policy_arn = string
      access_scope = object({
        type       = string
        namespaces = optional(list(string), [])
      })
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

# =============================================================================
# Pod Identity Associations Configuration
# =============================================================================
variable "pod_identity_associations" {
  description = "Map of EKS Pod Identity associations"
  type = map(object({
    namespace       = string
    service_account = string
    role_arn        = string
    tags            = optional(map(string), {})
  }))
  default = {}
}

# =============================================================================
# Tags
# =============================================================================
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "cluster_tags" {
  description = "Additional tags specific to the EKS cluster"
  type        = map(string)
  default     = {}
}
