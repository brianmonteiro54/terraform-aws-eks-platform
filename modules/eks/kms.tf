# =============================================================================
# KMS Key for EKS Secrets Encryption (Optional)
# =============================================================================
resource "aws_kms_key" "eks" {
  count = var.enable_secrets_encryption && var.create_kms_key ? 1 : 0

  description         = "KMS key for EKS secrets encryption (${var.cluster_name})"
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.cluster_name}-eks-secrets-key-policy"
    Statement = [
      {
        Sid    = "EnableRootAccountFullAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowEKSClusterUsage"
        Effect = "Allow"
        Principal = {
          AWS = local.cluster_role_arn
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-eks-secrets-kms" })
}

resource "aws_kms_alias" "eks" {
  count = var.enable_secrets_encryption && var.create_kms_key ? 1 : 0

  name          = "alias/${var.cluster_name}-eks-secrets"
  target_key_id = aws_kms_key.eks[0].key_id
}
