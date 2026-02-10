
variable "tags" {
  description = "Tags globais aplicadas em recursos do módulo"
  type        = map(string)
  default     = {}
}

variable "cluster_tags" {
  description = "Tags específicas do cluster (ex: Environment, Name, etc.)"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
}

variable "cluster_role_arn" {
  description = "IAM Role ARN do control plane do EKS"
  type        = string
}

variable "cluster_subnet_ids" {
  description = "Lista de subnets onde o control plane do EKS cria ENIs (recomendado: privadas, >=2 AZs)"
  type        = list(string)

  validation {
    condition     = length(var.cluster_subnet_ids) >= 2
    error_message = "cluster_subnet_ids deve ter pelo menos 2 subnets (idealmente em AZs diferentes)."
  }
}

variable "cluster_security_group_ids" {
  description = "Security Groups adicionais anexados às ENIs do control plane do EKS (opcional)"
  type        = list(string)
  default     = []
}

variable "endpoint_private_access" {
  description = "Enable private access to EKS API endpoint"
  type        = bool
}

variable "endpoint_public_access" {
  description = "Enable public access to EKS API endpoint"
  type        = bool
}

variable "service_ipv4_cidr" {
  description = "Service CIDR block for Kubernetes services"
  type        = string
}

variable "ip_family" {
  description = "IP family for Kubernetes networking (ipv4 or ipv6)"
  type        = string
  validation {
    condition     = contains(["ipv4", "ipv6"], var.ip_family)
    error_message = "ip_family deve ser 'ipv4' ou 'ipv6'."
  }
}

variable "enabled_cluster_log_types" {
  description = "List of control plane logging types to enable"
  type        = list(string)
  default     = []
}

variable "support_type" {
  description = "Support type for the cluster (STANDARD or EXTENDED)"
  type        = string
  default     = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "EXTENDED"], var.support_type)
    error_message = "support_type deve ser 'STANDARD' ou 'EXTENDED'."
  }
}

variable "deletion_protection" {
  description = "Enable deletion protection for the cluster"
  type        = bool
  default     = false
}

variable "authentication_mode" {
  description = "EKS cluster authentication mode (CONFIG_MAP, API, API_AND_CONFIG_MAP)"
  type        = string
  validation {
    condition     = contains(["CONFIG_MAP", "API", "API_AND_CONFIG_MAP"], var.authentication_mode)
    error_message = "authentication_mode deve ser CONFIG_MAP, API ou API_AND_CONFIG_MAP."
  }
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Grant admin permissions to cluster creator"
  type        = bool
}

variable "cluster_encryption_config" {
  description = "Config opcional para criptografar secrets do Kubernetes via KMS"
  type = object({
    provider_key_arn = string
    resources        = list(string)
  })
  default = null
}

variable "worker_security_group_ids" {
  description = "Security groups anexados às instâncias (workers)"
  type        = list(string)
  validation {
    condition     = length(var.worker_security_group_ids) > 0
    error_message = "worker_security_group_ids deve ter pelo menos 1 security group."
  }
}

variable "launch_template_name" {
  description = "Name of the EKS workers launch template"
  type        = string
}

variable "launch_template_instance_type" {
  description = "Instance type for EKS worker nodes (se instance_types do nodegroup estiver vazio, LT manda)"
  type        = string
}

variable "launch_template_update_default_version" {
  description = "Update default version on each update"
  type        = bool
}

variable "launch_template_volume_size" {
  description = "EBS volume size in GB for EKS workers"
  type        = number
}

variable "launch_template_volume_type" {
  description = "EBS volume type for EKS workers"
  type        = string
}

variable "launch_template_volume_iops" {
  description = "IOPS for EKS worker EBS volume"
  type        = number
}

variable "launch_template_device_name" {
  description = "Device name for the EBS volume"
  type        = string
}

variable "launch_template_delete_on_termination" {
  description = "Delete EBS volume on instance termination"
  type        = bool
}

variable "launch_template_encrypted" {
  description = "Encrypt the EBS volume"
  type        = bool
}

variable "launch_template_ebs_optimized" {
  description = "Enable EBS optimization"
  type        = bool
}

variable "launch_template_metadata" {
  description = "Metadata options for the launch template"
  type = object({
    http_endpoint               = string
    http_tokens                 = string
    http_put_response_hop_limit = number
    instance_metadata_tags      = string
  })
}

variable "launch_template_worker_tag" {
  description = "Name tag for EKS worker instances and volumes"
  type        = string
}

variable "launch_template_tag_resource_types" {
  description = "Resource types for tag specifications"
  type        = list(string)
}

variable "node_role_arn" {
  description = "IAM Role ARN para os managed node groups"
  type        = string
}

variable "nodegroups" {
  description = "Map of node groups to create"
  type = map(object({
    scaling_min     = number
    scaling_max     = number
    scaling_desired = number
    ami_type        = string
    capacity_type   = string
    instance_types  = optional(list(string), [])
    version         = optional(string, null)
    release_version = optional(string, null)
    labels          = optional(map(string), {})
    tags            = optional(map(string), {})
  }))
  default = {}
}

variable "nodegroup_subnet_ids" {
  description = "Subnets usadas pelos node groups (normalmente as privadas)"
  type        = list(string)
  validation {
    condition     = length(var.nodegroup_subnet_ids) >= 1
    error_message = "nodegroup_subnet_ids deve ter pelo menos 1 subnet."
  }
}

variable "nodegroup_az_mapping" {
  description = "Map de nodegroup name -> índice de subnet em nodegroup_subnet_ids (0,1,2...)"
  type        = map(number)
  default     = {}

  validation {
    condition = alltrue([
      for _, idx in var.nodegroup_az_mapping :
      idx >= 0 && idx < length(var.nodegroup_subnet_ids)
    ])
    error_message = "nodegroup_az_mapping contém índice fora do range de nodegroup_subnet_ids."
  }
}

variable "nodegroup_max_unavailable" {
  description = "Max unavailable nodes during update"
  type        = number
  default     = 1
}

variable "nodegroup_timeouts" {
  description = "Timeouts do recurso aws_eks_node_group"
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

variable "addons" {
  description = "EKS add-ons configuration"
  type = map(object({
    addon_version            = string
    configuration_values     = optional(string, null)

    # compatibilidade com seu tfvars atual:
    resolve_conflicts        = optional(string, "OVERWRITE")

    # se quiser granularidade:
    resolve_conflicts_on_create = optional(string, null)
    resolve_conflicts_on_update = optional(string, null)

    service_account_role_arn = optional(string, null)
    tags                     = optional(map(string), {})
  }))
  default = {}
}

variable "fargate_profiles" {
  description = "Map of Fargate profiles to create"
  type = map(object({
    pod_execution_role_arn = string
    subnet_ids             = list(string)
    selectors = list(object({
      namespace = string
      labels    = optional(map(string), {})
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "access_entries" {
  description = "Map of IAM access entries to create"
  type = map(object({
    principal_arn     = string
    kubernetes_groups = optional(list(string), [])
    type              = string
    user_name         = optional(string)
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

variable "pod_identity_associations" {
  description = "EKS Pod Identity Associations"
  type = map(object({
    namespace       = string
    service_account = string
    role_arn        = string
    tags            = optional(map(string), {})
  }))
  default = {}
}