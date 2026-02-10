# =============================================================================
# Data Sources
# =============================================================================

# Current AWS region
data "aws_region" "current" {}

# Current AWS account ID
data "aws_caller_identity" "current" {}

# Current AWS partition (aws, aws-cn, aws-us-gov)
data "aws_partition" "current" {}

# EKS cluster auth data (for kubectl configuration)
data "aws_eks_cluster_auth" "cluster" {
  count = var.create_cluster ? 1 : 0
  name  = aws_eks_cluster.main[0].name
}
