# EKS Module

Módulo Terraform para criação de EKS na AWS.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.31 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.32.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_access_entry.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_policy_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association) | resource |
| [aws_eks_addon.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_fargate_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_fargate_profile) | resource |
| [aws_eks_node_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_eks_pod_identity_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_pod_identity_association) | resource |
| [aws_iam_role.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.fargate_pod_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cluster_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.cluster_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_service_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.fargate_pod_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_cni_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_registry_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_ssm_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_worker_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_launch_template.eks_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group_rule.cluster_ingress_workstation_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | Map of IAM principals to grant cluster access | <pre>map(object({<br/>    principal_arn     = string<br/>    kubernetes_groups = optional(list(string), [])<br/>    type              = string<br/>    user_name         = optional(string, null)<br/>    policy_associations = optional(list(object({<br/>      policy_arn = string<br/>      access_scope = object({<br/>        type       = string<br/>        namespaces = optional(list(string), [])<br/>      })<br/>    })), [])<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_addons"></a> [addons](#input\_addons) | Map of EKS add-ons to install | <pre>map(object({<br/>    addon_version               = string<br/>    configuration_values        = optional(string, null)<br/>    resolve_conflicts           = optional(string, "OVERWRITE")<br/>    resolve_conflicts_on_create = optional(string, null)<br/>    resolve_conflicts_on_update = optional(string, null)<br/>    preserve                    = optional(bool, false)<br/>    service_account_role_arn    = optional(string, null)<br/>    tags                        = optional(map(string), {})<br/>    timeouts = optional(object({<br/>      create = string<br/>      update = string<br/>      delete = string<br/>      }), {<br/>      create = "20m"<br/>      update = "20m"<br/>      delete = "40m"<br/>    })<br/>  }))</pre> | `{}` | no |
| <a name="input_authentication_mode"></a> [authentication\_mode](#input\_authentication\_mode) | Authentication mode for the cluster (CONFIG\_MAP, API, or API\_AND\_CONFIG\_MAP) | `string` | `"API_AND_CONFIG_MAP"` | no |
| <a name="input_bootstrap_cluster_creator_admin_permissions"></a> [bootstrap\_cluster\_creator\_admin\_permissions](#input\_bootstrap\_cluster\_creator\_admin\_permissions) | Grant cluster creator admin permissions automatically | `bool` | `true` | no |
| <a name="input_cluster_encryption_config"></a> [cluster\_encryption\_config](#input\_cluster\_encryption\_config) | Configuration for envelope encryption of Kubernetes secrets using KMS | <pre>object({<br/>    provider_key_arn = string<br/>    resources        = list(string)<br/>  })</pre> | `null` | no |
| <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster\_endpoint\_public\_access\_cidrs](#input\_cluster\_endpoint\_public\_access\_cidrs) | List of CIDR blocks that can access the public API server endpoint | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_cluster_kms_key_arn"></a> [cluster\_kms\_key\_arn](#input\_cluster\_kms\_key\_arn) | Existing KMS key ARN for EKS secrets encryption. Only used when create\_kms\_key=true. If null, a new CMK is created. | `string` | `null` | no |
| <a name="input_cluster_logging_enabled"></a> [cluster\_logging\_enabled](#input\_cluster\_logging\_enabled) | Enable cluster control plane logging | `bool` | `true` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_cluster_role_arn"></a> [cluster\_role\_arn](#input\_cluster\_role\_arn) | IAM Role ARN for the EKS cluster control plane (required if create\_iam\_roles is false). For AWS Academy, use LabRole ARN. | `string` | `null` | no |
| <a name="input_cluster_security_group_additional_rules"></a> [cluster\_security\_group\_additional\_rules](#input\_cluster\_security\_group\_additional\_rules) | Additional security group rules to add to the cluster security group | <pre>list(object({<br/>    description = string<br/>    type        = string<br/>    from_port   = number<br/>    to_port     = number<br/>    protocol    = string<br/>    cidr_blocks = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_cluster_security_group_ids"></a> [cluster\_security\_group\_ids](#input\_cluster\_security\_group\_ids) | Additional security group IDs to attach to the cluster control plane ENIs | `list(string)` | `[]` | no |
| <a name="input_cluster_subnet_ids"></a> [cluster\_subnet\_ids](#input\_cluster\_subnet\_ids) | List of subnet IDs for the EKS cluster control plane (recommended: private subnets in multiple AZs) | `list(string)` | `[]` | no |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | Additional tags specific to the EKS cluster | `map(string)` | `{}` | no |
| <a name="input_cluster_timeouts"></a> [cluster\_timeouts](#input\_cluster\_timeouts) | Timeout configuration for cluster operations | <pre>object({<br/>    create = string<br/>    update = string<br/>    delete = string<br/>  })</pre> | <pre>{<br/>  "create": "30m",<br/>  "delete": "15m",<br/>  "update": "60m"<br/>}</pre> | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes version to use for the EKS cluster | `string` | `"1.31"` | no |
| <a name="input_create_cluster"></a> [create\_cluster](#input\_create\_cluster) | Controls if EKS cluster should be created (affects all resources) | `bool` | `true` | no |
| <a name="input_create_iam_roles"></a> [create\_iam\_roles](#input\_create\_iam\_roles) | Create IAM roles for cluster and nodes. If false, must provide cluster\_role\_arn and node\_role\_arn. Set to false for AWS Academy environments. | `bool` | `false` | no |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Create a customer managed KMS key. When false, AWS managed encryption is used. When true and cluster\_kms\_key\_arn is null, a new CMK is created. When true and cluster\_kms\_key\_arn is provided, uses the existing key. | `bool` | `false` | no |
| <a name="input_create_launch_template"></a> [create\_launch\_template](#input\_create\_launch\_template) | Create launch template for node groups | `bool` | `true` | no |
| <a name="input_create_node_groups"></a> [create\_node\_groups](#input\_create\_node\_groups) | Create managed node groups | `bool` | `true` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Enable deletion protection for the cluster | `bool` | `false` | no |
| <a name="input_enable_secrets_encryption"></a> [enable\_secrets\_encryption](#input\_enable\_secrets\_encryption) | Enable EKS secrets encryption. When true with create\_kms\_key=false, uses AWS managed encryption. When true with create\_kms\_key=true, creates or uses a CMK. | `bool` | `true` | no |
| <a name="input_enable_ssm_access"></a> [enable\_ssm\_access](#input\_enable\_ssm\_access) | Enable AWS Systems Manager access for node groups | `bool` | `true` | no |
| <a name="input_enabled_cluster_log_types"></a> [enabled\_cluster\_log\_types](#input\_enabled\_cluster\_log\_types) | List of control plane logging types to enable | `list(string)` | <pre>[<br/>  "api",<br/>  "audit",<br/>  "authenticator",<br/>  "controllerManager",<br/>  "scheduler"<br/>]</pre> | no |
| <a name="input_endpoint_private_access"></a> [endpoint\_private\_access](#input\_endpoint\_private\_access) | Enable private API server endpoint | `bool` | `true` | no |
| <a name="input_endpoint_public_access"></a> [endpoint\_public\_access](#input\_endpoint\_public\_access) | Enable public API server endpoint | `bool` | `false` | no |
| <a name="input_fargate_profiles"></a> [fargate\_profiles](#input\_fargate\_profiles) | Map of Fargate profiles to create | <pre>map(object({<br/>    pod_execution_role_arn = optional(string, null)<br/>    subnet_ids             = list(string)<br/>    selectors = list(object({<br/>      namespace = string<br/>      labels    = optional(map(string), {})<br/>    }))<br/>    tags = optional(map(string), {})<br/>    timeouts = optional(object({<br/>      create = string<br/>      delete = string<br/>      }), {<br/>      create = "10m"<br/>      delete = "10m"<br/>    })<br/>  }))</pre> | `{}` | no |
| <a name="input_ip_family"></a> [ip\_family](#input\_ip\_family) | IP family for Kubernetes networking (ipv4 or ipv6) | `string` | `"ipv4"` | no |
| <a name="input_launch_template_additional_tags"></a> [launch\_template\_additional\_tags](#input\_launch\_template\_additional\_tags) | Additional tags for launch template and resources | `map(string)` | `{}` | no |
| <a name="input_launch_template_delete_on_termination"></a> [launch\_template\_delete\_on\_termination](#input\_launch\_template\_delete\_on\_termination) | Whether to delete EBS volume on instance termination | `bool` | `true` | no |
| <a name="input_launch_template_description"></a> [launch\_template\_description](#input\_launch\_template\_description) | Description of the launch template | `string` | `null` | no |
| <a name="input_launch_template_device_name"></a> [launch\_template\_device\_name](#input\_launch\_template\_device\_name) | Device name for the root EBS volume | `string` | `"/dev/xvda"` | no |
| <a name="input_launch_template_ebs_optimized"></a> [launch\_template\_ebs\_optimized](#input\_launch\_template\_ebs\_optimized) | Enable EBS optimization | `bool` | `true` | no |
| <a name="input_launch_template_enable_monitoring"></a> [launch\_template\_enable\_monitoring](#input\_launch\_template\_enable\_monitoring) | Enable detailed CloudWatch monitoring | `bool` | `true` | no |
| <a name="input_launch_template_encrypted"></a> [launch\_template\_encrypted](#input\_launch\_template\_encrypted) | Enable EBS volume encryption | `bool` | `true` | no |
| <a name="input_launch_template_instance_type"></a> [launch\_template\_instance\_type](#input\_launch\_template\_instance\_type) | Default instance type for worker nodes | `string` | `"t3.medium"` | no |
| <a name="input_launch_template_kms_key_id"></a> [launch\_template\_kms\_key\_id](#input\_launch\_template\_kms\_key\_id) | KMS key ID for EBS encryption (uses AWS managed key if not specified) | `string` | `null` | no |
| <a name="input_launch_template_metadata_options"></a> [launch\_template\_metadata\_options](#input\_launch\_template\_metadata\_options) | Instance metadata service configuration | <pre>object({<br/>    http_endpoint               = string<br/>    http_tokens                 = string<br/>    http_put_response_hop_limit = number<br/>    instance_metadata_tags      = string<br/>  })</pre> | <pre>{<br/>  "http_endpoint": "enabled",<br/>  "http_put_response_hop_limit": 2,<br/>  "http_tokens": "required",<br/>  "instance_metadata_tags": "enabled"<br/>}</pre> | no |
| <a name="input_launch_template_name"></a> [launch\_template\_name](#input\_launch\_template\_name) | Name of the launch template (defaults to cluster-name-node-template) | `string` | `null` | no |
| <a name="input_launch_template_network_interfaces"></a> [launch\_template\_network\_interfaces](#input\_launch\_template\_network\_interfaces) | Network interface configuration for launch template | <pre>list(object({<br/>    associate_public_ip_address = bool<br/>    delete_on_termination       = bool<br/>    description                 = string<br/>    device_index                = number<br/>    security_groups             = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_launch_template_tag_resource_types"></a> [launch\_template\_tag\_resource\_types](#input\_launch\_template\_tag\_resource\_types) | Resource types to tag (instance, volume, network-interface) | `list(string)` | <pre>[<br/>  "instance",<br/>  "volume"<br/>]</pre> | no |
| <a name="input_launch_template_update_default_version"></a> [launch\_template\_update\_default\_version](#input\_launch\_template\_update\_default\_version) | Whether to update default version on each launch template update | `bool` | `true` | no |
| <a name="input_launch_template_user_data_base64"></a> [launch\_template\_user\_data\_base64](#input\_launch\_template\_user\_data\_base64) | Base64-encoded user data for bootstrapping nodes | `string` | `null` | no |
| <a name="input_launch_template_volume_iops"></a> [launch\_template\_volume\_iops](#input\_launch\_template\_volume\_iops) | IOPS for the EBS volume (only for gp3, io1, io2). Leave null for auto-calculation | `number` | `null` | no |
| <a name="input_launch_template_volume_size"></a> [launch\_template\_volume\_size](#input\_launch\_template\_volume\_size) | Size of the EBS volume in GB | `number` | `50` | no |
| <a name="input_launch_template_volume_throughput"></a> [launch\_template\_volume\_throughput](#input\_launch\_template\_volume\_throughput) | Throughput in MB/s for gp3 volumes | `number` | `125` | no |
| <a name="input_launch_template_volume_type"></a> [launch\_template\_volume\_type](#input\_launch\_template\_volume\_type) | Type of EBS volume (gp3, gp2, io1, io2) | `string` | `"gp3"` | no |
| <a name="input_launch_template_worker_tag"></a> [launch\_template\_worker\_tag](#input\_launch\_template\_worker\_tag) | Name tag for worker instances (defaults to cluster-name-node) | `string` | `null` | no |
| <a name="input_node_role_arn"></a> [node\_role\_arn](#input\_node\_role\_arn) | IAM Role ARN for EKS node groups (required if create\_iam\_roles is false). For AWS Academy, use LabRole ARN. | `string` | `null` | no |
| <a name="input_nodegroup_az_mapping"></a> [nodegroup\_az\_mapping](#input\_nodegroup\_az\_mapping) | Map nodegroup name to specific subnet index for AZ pinning | `map(number)` | `{}` | no |
| <a name="input_nodegroup_max_unavailable"></a> [nodegroup\_max\_unavailable](#input\_nodegroup\_max\_unavailable) | Default max unavailable nodes during updates | `number` | `1` | no |
| <a name="input_nodegroup_subnet_ids"></a> [nodegroup\_subnet\_ids](#input\_nodegroup\_subnet\_ids) | Subnet IDs for node groups (typically private subnets) | `list(string)` | `[]` | no |
| <a name="input_nodegroup_timeouts"></a> [nodegroup\_timeouts](#input\_nodegroup\_timeouts) | Timeout configuration for node group operations | <pre>object({<br/>    create = string<br/>    update = string<br/>    delete = string<br/>  })</pre> | <pre>{<br/>  "create": "60m",<br/>  "delete": "60m",<br/>  "update": "60m"<br/>}</pre> | no |
| <a name="input_nodegroups"></a> [nodegroups](#input\_nodegroups) | Map of EKS managed node groups to create | <pre>map(object({<br/>    scaling_min     = number<br/>    scaling_max     = number<br/>    scaling_desired = number<br/>    ami_type        = optional(string, "AL2_x86_64")<br/>    capacity_type   = optional(string, "ON_DEMAND")<br/>    disk_size       = optional(number, null)<br/>    instance_types  = optional(list(string), [])<br/>    version         = optional(string, null)<br/>    release_version = optional(string, null)<br/>    labels          = optional(map(string), {})<br/>    taints = optional(list(object({<br/>      key    = string<br/>      value  = string<br/>      effect = string<br/>    })), [])<br/>    max_unavailable           = optional(number, null)<br/>    remote_access_enabled     = optional(bool, false)<br/>    ec2_ssh_key               = optional(string, null)<br/>    source_security_group_ids = optional(list(string), [])<br/>    tags                      = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_pod_identity_associations"></a> [pod\_identity\_associations](#input\_pod\_identity\_associations) | Map of EKS Pod Identity associations | <pre>map(object({<br/>    namespace       = string<br/>    service_account = string<br/>    role_arn        = string<br/>    tags            = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_service_ipv4_cidr"></a> [service\_ipv4\_cidr](#input\_service\_ipv4\_cidr) | CIDR block for Kubernetes services (must not overlap with VPC CIDR) | `string` | `"172.20.0.0/16"` | no |
| <a name="input_support_type"></a> [support\_type](#input\_support\_type) | EKS support type (STANDARD or EXTENDED) | `string` | `"STANDARD"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_worker_security_group_ids"></a> [worker\_security\_group\_ids](#input\_worker\_security\_group\_ids) | Security group IDs for worker nodes | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_entries"></a> [access\_entries](#output\_access\_entries) | Map of access entries created |
| <a name="output_addon_versions"></a> [addon\_versions](#output\_addon\_versions) | Map of add-on names to installed versions |
| <a name="output_cluster_addons"></a> [cluster\_addons](#output\_cluster\_addons) | Map of attribute maps for all EKS cluster addons |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The Amazon Resource Name (ARN) of the cluster |
| <a name="output_cluster_auth_token"></a> [cluster\_auth\_token](#output\_cluster\_auth\_token) | Auth token for kubectl configuration (expires in 15 minutes) |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Base64 encoded certificate data required to communicate with the cluster |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for your Kubernetes API server |
| <a name="output_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#output\_cluster\_iam\_role\_arn) | IAM role ARN of the EKS cluster |
| <a name="output_cluster_iam_role_name"></a> [cluster\_iam\_role\_name](#output\_cluster\_iam\_role\_name) | IAM role name of the EKS cluster |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The ID/name of the EKS cluster |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the EKS cluster |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | The URL on the EKS cluster OIDC Issuer |
| <a name="output_cluster_platform_version"></a> [cluster\_platform\_version](#output\_cluster\_platform\_version) | The platform version for the cluster |
| <a name="output_cluster_security_group_arn"></a> [cluster\_security\_group\_arn](#output\_cluster\_security\_group\_arn) | Amazon Resource Name (ARN) of the cluster security group |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | Security group ID attached to the EKS cluster control plane |
| <a name="output_cluster_status"></a> [cluster\_status](#output\_cluster\_status) | Status of the EKS cluster |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | The Kubernetes version for the cluster |
| <a name="output_fargate_iam_role_arn"></a> [fargate\_iam\_role\_arn](#output\_fargate\_iam\_role\_arn) | IAM role ARN for Fargate pod execution |
| <a name="output_fargate_iam_role_name"></a> [fargate\_iam\_role\_name](#output\_fargate\_iam\_role\_name) | IAM role name for Fargate pod execution |
| <a name="output_fargate_profile_arns"></a> [fargate\_profile\_arns](#output\_fargate\_profile\_arns) | Map of Fargate profile names to ARNs |
| <a name="output_fargate_profile_ids"></a> [fargate\_profile\_ids](#output\_fargate\_profile\_ids) | Map of Fargate profile names to IDs |
| <a name="output_fargate_profiles"></a> [fargate\_profiles](#output\_fargate\_profiles) | Map of attribute maps for all EKS Fargate profiles |
| <a name="output_kubeconfig_command"></a> [kubeconfig\_command](#output\_kubeconfig\_command) | Command to update local kubeconfig |
| <a name="output_launch_template_arn"></a> [launch\_template\_arn](#output\_launch\_template\_arn) | ARN of the launch template |
| <a name="output_launch_template_default_version"></a> [launch\_template\_default\_version](#output\_launch\_template\_default\_version) | Default version of the launch template |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | ID of the launch template |
| <a name="output_launch_template_latest_version"></a> [launch\_template\_latest\_version](#output\_launch\_template\_latest\_version) | Latest version of the launch template |
| <a name="output_launch_template_name"></a> [launch\_template\_name](#output\_launch\_template\_name) | Name of the launch template |
| <a name="output_node_group_arns"></a> [node\_group\_arns](#output\_node\_group\_arns) | Map of node group names to ARNs |
| <a name="output_node_group_ids"></a> [node\_group\_ids](#output\_node\_group\_ids) | Map of node group names to IDs |
| <a name="output_node_group_statuses"></a> [node\_group\_statuses](#output\_node\_group\_statuses) | Map of node group names to status |
| <a name="output_node_groups"></a> [node\_groups](#output\_node\_groups) | Map of attribute maps for all EKS node groups created |
| <a name="output_node_iam_role_arn"></a> [node\_iam\_role\_arn](#output\_node\_iam\_role\_arn) | IAM role ARN of the EKS nodes |
| <a name="output_node_iam_role_name"></a> [node\_iam\_role\_name](#output\_node\_iam\_role\_name) | IAM role name of the EKS nodes |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | ARN of the OIDC Provider for EKS (useful for IRSA) |
| <a name="output_pod_identity_associations"></a> [pod\_identity\_associations](#output\_pod\_identity\_associations) | Map of Pod Identity associations |
<!-- END_TF_DOCS -->