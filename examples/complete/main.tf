# =============================================================================
# Example: Complete EKS Cluster (AWS Academy Compatible)
#
# This example provisions a production-ready EKS cluster with:
#   - Kubernetes 1.31 with private API endpoint only
#   - All control plane log types enabled (api, audit, authenticator, etc.)
#   - Secrets encryption via AWS-managed KMS (compatible with AWS Academy)
#   - Launch template with IMDSv2 enforced, EBS encrypted, gp3 50 GB volumes
#   - Two managed node groups: general-purpose (ON_DEMAND) and spot (SPOT)
#   - Core EKS add-ons: vpc-cni, coredns, kube-proxy, aws-ebs-csi-driver
#   - EKS access entries for cluster admin and read-only access
#
# AWS Academy notes:
#   - create_iam_roles = false  → provide LabRole ARN via lab_role_arn
#   - create_kms_key   = false  → uses AWS-managed secrets encryption
#   - Fargate profiles omitted  → require dedicated IAM role creation
#
# Usage:
#   terraform init
#   terraform plan \
#     -var='cluster_subnet_ids=["subnet-aaa","subnet-bbb"]' \
#     -var='nodegroup_subnet_ids=["subnet-aaa","subnet-bbb"]' \
#     -var='worker_security_group_id=sg-xxxx' \
#     -var='lab_role_arn=arn:aws:iam::123456789012:role/LabRole'
#   terraform apply ...
# =============================================================================

module "eks" {
  source = "../../modules/eks"

  # ---------------------------------------------------
  # Cluster identity
  # ---------------------------------------------------
  cluster_name    = "my-app-cluster"
  cluster_version = "1.34"

  # ---------------------------------------------------
  # Network — control plane lives in private subnets
  # ---------------------------------------------------
  cluster_subnet_ids      = var.cluster_subnet_ids
  nodegroup_subnet_ids    = var.nodegroup_subnet_ids
  endpoint_private_access = true
  endpoint_public_access  = false # Keep the API server private
  service_ipv4_cidr       = "172.20.0.0/16"
  ip_family               = "ipv4"

  # ---------------------------------------------------
  # Authentication — API + ConfigMap for maximum compatibility
  # ---------------------------------------------------
  authentication_mode                         = "API_AND_CONFIG_MAP"
  bootstrap_cluster_creator_admin_permissions = true

  # ---------------------------------------------------
  # IAM — AWS Academy: use LabRole, don't create new roles
  # ---------------------------------------------------
  create_iam_roles  = false
  cluster_role_arn  = var.lab_role_arn
  node_role_arn     = var.lab_role_arn
  enable_ssm_access = true # SSM access for nodes (no SSH keys needed)

  # ---------------------------------------------------
  # Secrets encryption
  # create_kms_key = false → uses AWS-managed KMS (no extra IAM needed)
  # Set create_kms_key = true for a customer-managed key in production
  # ---------------------------------------------------
  enable_secrets_encryption = true
  create_kms_key            = false

  # ---------------------------------------------------
  # Control plane logging — all types enabled
  # ---------------------------------------------------
  cluster_logging_enabled = true
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  # ---------------------------------------------------
  # Launch template — IMDSv2 enforced, EBS encrypted
  # ---------------------------------------------------
  create_launch_template            = true
  worker_security_group_ids         = [var.worker_security_group_id]
  launch_template_instance_type     = "t3.medium"
  launch_template_volume_size       = 50
  launch_template_volume_type       = "gp3"
  launch_template_encrypted         = true # EBS volumes encrypted
  launch_template_enable_monitoring = true

  launch_template_metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 — blocks credential theft
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  # ---------------------------------------------------
  # Node groups
  # ---------------------------------------------------
  create_node_groups = true

  nodegroups = {
    # General-purpose ON_DEMAND nodes — stable workloads
    general = {
      scaling_min     = 2
      scaling_max     = 6
      scaling_desired = 2
      ami_type        = "AL2_x86_64"
      capacity_type   = "ON_DEMAND"
      instance_types  = ["t3.medium"]
      labels = {
        "role" = "general"
      }
    }

    # Cost-optimised SPOT nodes — batch / fault-tolerant workloads
    spot = {
      scaling_min     = 0
      scaling_max     = 10
      scaling_desired = 2
      ami_type        = "AL2_x86_64"
      capacity_type   = "SPOT"
      instance_types  = ["t3.medium", "t3.large", "t3a.medium"]
      labels = {
        "role"                             = "spot"
        "node.kubernetes.io/capacity-type" = "spot"
      }
      taints = [
        {
          key    = "spot"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }

  # ---------------------------------------------------
  # EKS Add-ons — pinned versions, OVERWRITE on conflict
  # Run: aws eks describe-addon-versions --kubernetes-version 1.31
  # to find the latest version for each add-on.
  # ---------------------------------------------------
  addons = {
    vpc-cni = {
      addon_version = "v1.19.0-eksbuild.1"
    }
    coredns = {
      addon_version = "v1.11.3-eksbuild.1"
    }
    kube-proxy = {
      addon_version = "v1.31.2-eksbuild.3"
    }
    aws-ebs-csi-driver = {
      addon_version            = "v1.37.0-eksbuild.1"
      service_account_role_arn = var.lab_role_arn # Required for EBS CSI
    }
  }

  # ---------------------------------------------------
  # Access entries — grant cluster-admin to LabRole
  # and read-only to a read-only IAM role
  # ---------------------------------------------------
  access_entries = {
    lab-admin = {
      principal_arn = var.lab_role_arn
      type          = "STANDARD"
      policy_associations = [
        {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      ]
    }
  }

  # ---------------------------------------------------
  # Deletion protection & timeouts
  # ---------------------------------------------------
  deletion_protection = false # Set true in production

  cluster_timeouts = {
    create = "30m"
    update = "60m"
    delete = "15m"
  }

  nodegroup_timeouts = {
    create = "60m"
    update = "60m"
    delete = "60m"
  }

  # ---------------------------------------------------
  # Tags
  # ---------------------------------------------------
  tags = {
    Environment = "dev"
    Project     = "my-app"
    Owner       = "platform-team"
    CostCenter  = "engineering"
  }

  cluster_tags = {
    "k8s.io/cluster-autoscaler/enabled"        = "true"
    "k8s.io/cluster-autoscaler/my-app-cluster" = "owned"
  }
}
