# ☸️ Terraform AWS EKS Platform

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.9.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/AWS%20Provider-~%3E%206.31-FF9900?logo=amazonaws)](https://registry.terraform.io/providers/hashicorp/aws/latest)

> **FIAP — Pós Tech · Tech Challenge — Fase 03 · ToggleMaster**
>
> Módulo Terraform para provisionamento de **Cluster Amazon EKS** completo com Node Groups, Launch Templates, Addons, Fargate e suporte a AWS Academy (LabRole).

---

## 📋 Descrição

Módulo production-ready que provisiona e gerencia um cluster EKS com:

- **Cluster EKS** com versão configurável do Kubernetes
- **Managed Node Groups** com Launch Templates customizados
- **EKS Addons** (CoreDNS, kube-proxy, VPC-CNI, Pod Identity Agent)
- **Fargate Profiles** (opcional)
- **Access Entries** e autenticação API/ConfigMap
- **Secrets Encryption** com KMS (opcional)
- **Pod Identity Associations**
- **Compatibilidade AWS Academy** — suporte à LabRole sem criação de IAM

---

## 📦 Recursos Criados

| Recurso | Descrição |
|---------|-----------|
| `aws_eks_cluster` | Cluster EKS |
| `aws_eks_node_group` | Managed Node Groups (por AZ) |
| `aws_launch_template` | Launch Template com IMDSv2 e EBS otimizado |
| `aws_eks_addon` | Addons gerenciados |
| `aws_eks_access_entry` | Entradas de acesso IAM ao cluster |
| `aws_eks_fargate_profile` | Profiles Fargate (opcional) |
| `aws_eks_pod_identity_association` | Pod Identity (opcional) |
| `aws_kms_key` | Chave KMS para secrets encryption (opcional) |
| `aws_iam_role` | Roles IAM para cluster e nodes (quando `create_iam_roles = true`) |

---

## 🚀 Uso

```hcl
module "eks" {
  source = "github.com/brianmonteiro54/terraform-aws-eks-platform//modules/eks?ref=<commit-sha>"

  create_cluster         = true
  create_iam_roles       = false   # AWS Academy: usa LabRole
  create_launch_template = true
  create_node_groups     = true

  cluster_role_arn = data.aws_iam_role.lab_role.arn
  node_role_arn    = data.aws_iam_role.lab_role.arn

  cluster_name    = "ToggleMaster"
  cluster_version = "1.34"

  cluster_subnet_ids         = module.vpc.private_subnet_ids
  nodegroup_subnet_ids       = module.vpc.private_subnet_ids
  cluster_security_group_ids = [aws_security_group.eks_workers.id]

  endpoint_private_access = true
  endpoint_public_access  = false

  nodegroups = {
    "node-1a" = {
      scaling_min     = 1
      scaling_max     = 4
      scaling_desired = 1
      ami_type        = "AL2023_x86_64_STANDARD"
      capacity_type   = "ON_DEMAND"
    }
  }

  addons = {
    coredns    = { addon_version = "v1.13.2-eksbuild.1" }
    kube-proxy = { addon_version = "v1.34.3-eksbuild.2" }
    vpc-cni    = { addon_version = "v1.21.1-eksbuild.3" }
  }
}
```

---

## 🔑 AWS Academy vs Conta Pessoal

| Configuração | AWS Academy | Conta Pessoal |
|-------------|-------------|---------------|
| `create_iam_roles` | `false` | `true` |
| `cluster_role_arn` | `data.aws_iam_role.lab_role.arn` | Criado automaticamente |
| `node_role_arn` | `data.aws_iam_role.lab_role.arn` | Criado automaticamente |

---

## 📁 Estrutura

```
terraform-aws-eks-platform/
├── modules/
│   └── eks/
│       ├── main.tf
│       ├── nodegroups.tf
│       ├── launch_template.tf
│       ├── addons.tf
│       ├── access.tf
│       ├── fargate.tf
│       ├── pod_identity.tf
│       ├── iam.tf
│       ├── kms.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── locals.tf
│       ├── data.tf
│       └── provider.tf
├── .github/workflows/
│   └── terraform-ci.yml
└── LICENSE
```

---

## 📖 Documentação Auto-gerada

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

---

## 📄 Licença

[MIT License](LICENSE)
