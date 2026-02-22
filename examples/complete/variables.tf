variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_subnet_ids" {
  description = "Subnet IDs for the EKS control plane (min 2, different AZs, private recommended)"
  type        = list(string)
}

variable "nodegroup_subnet_ids" {
  description = "Subnet IDs for worker nodes (private subnets)"
  type        = list(string)
}

variable "worker_security_group_id" {
  description = "Security group ID to attach to worker nodes"
  type        = string
}

# AWS Academy: IAM role creation is restricted — provide LabRole ARN
variable "lab_role_arn" {
  description = "ARN of the AWS Academy LabRole (used for both cluster and node roles)"
  type        = string
}
