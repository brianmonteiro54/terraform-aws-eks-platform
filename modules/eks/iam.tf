# =============================================================================
# IAM Roles for EKS Cluster (Optional)
# =============================================================================
# NOTE: For AWS Academy, set create_iam_roles = false and provide LabRole ARN
# IAM role creation is disabled by default for AWS Academy compatibility

# EKS Cluster IAM Role
resource "aws_iam_role" "cluster" {
  count = var.create_iam_roles && var.create_cluster ? 1 : 0

  name        = "${var.cluster_name}-cluster-role"
  description = "EKS cluster IAM role for ${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.${data.aws_partition.current.dns_suffix}"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.cluster_name}-cluster-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  count = var.create_iam_roles && var.create_cluster ? 1 : 0

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "cluster_service_policy" {
  count = var.create_iam_roles && var.create_cluster ? 1 : 0

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster[0].name
}

# Optional: Cluster encryption policy for KMS
resource "aws_iam_role_policy" "cluster_encryption" {
  count = var.create_iam_roles && var.create_cluster && var.cluster_encryption_config != null ? 1 : 0

  name = "${var.cluster_name}-cluster-encryption"
  role = aws_iam_role.cluster[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:CreateGrant"
      ]
      Resource = var.cluster_encryption_config.provider_key_arn
    }]
  })
}

# =============================================================================
# IAM Roles for EKS Node Groups (Optional)
# =============================================================================

# EKS Node IAM Role
resource "aws_iam_role" "node" {
  count = var.create_iam_roles && var.create_cluster ? 1 : 0

  name        = "${var.cluster_name}-node-role"
  description = "EKS node group IAM role for ${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.${data.aws_partition.current.dns_suffix}"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.cluster_name}-node-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  count = var.create_iam_roles && var.create_cluster ? 1 : 0

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  count = var.create_iam_roles && var.create_cluster ? 1 : 0

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role_policy_attachment" "node_registry_policy" {
  count = var.create_iam_roles && var.create_cluster ? 1 : 0

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node[0].name
}

# Optional: SSM access for nodes
resource "aws_iam_role_policy_attachment" "node_ssm_policy" {
  count = var.create_iam_roles && var.create_cluster && var.enable_ssm_access ? 1 : 0

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.node[0].name
}

# =============================================================================
# IAM Role for Fargate Profiles (Optional)
# =============================================================================
resource "aws_iam_role" "fargate_pod_execution" {
  count = var.create_iam_roles && var.create_cluster && length(var.fargate_profiles) > 0 ? 1 : 0

  name        = "${var.cluster_name}-fargate-pod-execution-role"
  description = "EKS Fargate pod execution IAM role for ${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.${data.aws_partition.current.dns_suffix}"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.cluster_name}-fargate-pod-execution-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "fargate_pod_execution_policy" {
  count = var.create_iam_roles && var.create_cluster && length(var.fargate_profiles) > 0 ? 1 : 0

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_pod_execution[0].name
}
