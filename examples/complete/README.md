# Example: Complete EKS Cluster (AWS Academy Compatible)

This example provisions a production-ready EKS 1.31 cluster designed to work within AWS Academy environment constraints.

## What is created

- EKS 1.31 cluster with **private API endpoint only**
- All 5 control plane log types enabled (api, audit, authenticator, controllerManager, scheduler)
- Secrets encryption via AWS-managed KMS (no custom KMS key — AWS Academy compatible)
- Launch template with **IMDSv2 enforced** (`http_tokens = required`), EBS encrypted gp3 volumes (50 GB)
- Two managed node groups:
  - **general** — 2 × `t3.medium` ON_DEMAND for stable workloads
  - **spot** — 0–10 × `t3.medium/large/t3a.medium` SPOT for cost-optimised batch workloads
- Core EKS add-ons: `vpc-cni`, `coredns`, `kube-proxy`, `aws-ebs-csi-driver`
- EKS access entry granting `AmazonEKSClusterAdminPolicy` to the LabRole

## AWS Academy notes

| Feature | Setting | Reason |
|---------|---------|--------|
| `create_iam_roles` | `false` | IAM role creation is restricted in Academy |
| `cluster_role_arn` | LabRole ARN | Shared cluster control plane role |
| `node_role_arn` | LabRole ARN | Shared node group role |
| `create_kms_key` | `false` | CMK creation requires IAM permissions |
| Fargate profiles | Not included | Require dedicated execution role creation |

## Usage

```bash
terraform init

terraform plan \
  -var='cluster_subnet_ids=["subnet-aaa","subnet-bbb"]' \
  -var='nodegroup_subnet_ids=["subnet-aaa","subnet-bbb"]' \
  -var='worker_security_group_id=sg-xxxxxxxxxxxxxxxxx' \
  -var='lab_role_arn=arn:aws:iam::123456789012:role/LabRole'

terraform apply \
  -var='cluster_subnet_ids=["subnet-aaa","subnet-bbb"]' \
  -var='nodegroup_subnet_ids=["subnet-aaa","subnet-bbb"]' \
  -var='worker_security_group_id=sg-xxxxxxxxxxxxxxxxx' \
  -var='lab_role_arn=arn:aws:iam::123456789012:role/LabRole'
```

## Getting LabRole ARN

```bash
aws iam get-role --role-name LabRole --query Role.Arn --output text
```

## Connecting to the cluster

```bash
# Update kubeconfig
$(terraform output -raw kubeconfig_command)

# Verify connection
kubectl get nodes
kubectl get pods -A
```

## Inputs

| Name | Description | Required |
|------|-------------|----------|
| cluster_subnet_ids | Private subnet IDs for the control plane (min 2, different AZs) | Yes |
| nodegroup_subnet_ids | Private subnet IDs for worker nodes | Yes |
| worker_security_group_id | Security group for worker nodes | Yes |
| lab_role_arn | AWS Academy LabRole ARN | Yes |
| aws_region | AWS region | No (default: `us-east-1`) |

## Outputs

| Name | Description |
|------|-------------|
| cluster_name | EKS cluster name |
| cluster_endpoint | Kubernetes API server endpoint |
| oidc_provider_arn | OIDC provider ARN for IRSA/Pod Identity |
| kubeconfig_command | Ready-to-run `aws eks update-kubeconfig` command |
| node_groups | Node group status and scaling configuration |

> **Production checklist:** Set `endpoint_public_access = false` (already set),
> `deletion_protection = true`, `create_kms_key = true` (if IAM permits),
> and pin add-on versions with `aws eks describe-addon-versions --kubernetes-version 1.31`.

> **Cluster Autoscaler:** The `cluster_tags` block includes the required
> `k8s.io/cluster-autoscaler/*` tags. Deploy the Cluster Autoscaler Helm chart
> after the cluster is ready and point it to the LabRole for permissions.
