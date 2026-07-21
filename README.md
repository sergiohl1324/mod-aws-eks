# mod-aws-eks

Módulo de Terraform personalizado para crear un cluster EKS administrado, pensado para labs
de aprendizaje de bajo costo. Es un wrapper delgado sobre el módulo público
[`terraform-aws-modules/eks/aws`](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest),
con la misma convención de naming/tags (`project`/`environment`) que el resto de mis módulos
(`mod-aws-vpc`, `mod-aws-iam-role`, `mod-aws-security-group`).

## Por qué un wrapper y no una reimplementación raw

A diferencia de `mod-aws-vpc` (reimplementación completa desde recursos raw), replicar
`terraform-aws-modules/eks/aws` desde cero sería un módulo enorme (cluster IAM roles, node
IAM roles, launch templates, OIDC thumbprints, security groups, addons...). Para el objetivo
de este módulo (labs de aprendizaje EKS/ArgoCD/GitOps, no reinventar el motor de EKS), un
wrapper personalizado da el mismo control sobre las decisiones que importan (Spot, subnets
EKS dedicadas, endpoint público restringido a una IP, IRSA habilitado) sin la superficie de
mantenimiento de un fork completo.

## Uso

```hcl
module "eks" {
  source = "git::https://github.com/sergiohl1324/mod-aws-eks.git?ref=main"

  project     = "k8s-learning"
  environment = "lab"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.eks_subnets   # subnets dedicadas de mod-aws-vpc
  my_ip_cidr = "203.0.113.5/32"         # tu IP pública — curl ifconfig.me
}
```

Los roles IRSA de los addons (AWS Load Balancer Controller, External Secrets Operator, etc.)
**no se crean dentro de este módulo** — se crean en el repo consumidor con `mod-aws-iam-role`,
usando los outputs `oidc_provider_arn`/`oidc_provider` de abajo. Ver
[`k8s-learning`](https://github.com/sergiohl1324/k8s-learning) `main.tf` y `data.tf` para el
patrón completo.

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| project | Nombre del proyecto (naming/tags) | string | "poc" |
| environment | Ambiente lógico (lab, nonproduction, production) | string | "nonproduction" |
| tags | Tags adicionales | map(string) | {} |
| vpc_id | VPC donde se crea el cluster | string | — |
| subnet_ids | Subnets para cluster + node group | list(string) | — |
| my_ip_cidr | CIDR permitido en el endpoint público | string | — |
| cluster_version | Versión de Kubernetes | string | "1.31" |
| node_instance_types | Tipos de instancia del node group. t3.small soporta solo ~11 pods/nodo (límite de IPs del ENI) — t3.medium (~17/nodo sin prefix delegation) es el mínimo viable para ArgoCD+addons+monitoring. Desde 0.1.4 el addon vpc-cni usa prefix delegation (`ENABLE_PREFIX_DELEGATION=true`), que sube ese límite bastante más sin cambiar de instancia | list(string) | ["t3.medium"] |
| node_capacity_type | ON_DEMAND o SPOT | string | "SPOT" |
| node_min_size / node_max_size / node_desired_size | Escalado del node group | number | 1 / 3 / 2 |
| node_disk_size | Tamaño de disco EBS por nodo (GiB) | number | 20 |

## Outputs

| Name | Description |
|---|---|
| cluster_name | Nombre del cluster EKS |
| cluster_endpoint | Endpoint del API server |
| cluster_certificate_authority_data | CA del cluster (para kubeconfig) |
| cluster_version | Versión de Kubernetes activa |
| oidc_provider_arn | ARN del OIDC provider (Federated principal para IRSA) |
| oidc_provider | URL del issuer OIDC (para condiciones sub/aud en IRSA) |
| cluster_security_group_id | Security group del control plane |
| node_security_group_id | Security group del node group |

## Versionado

Ver `VERSION` / `CHANGELOG.md`. Este repo aún no tiene tags de git — se consume con `?ref=main`,
igual que el resto de mis módulos en `poc-aws-infra-deploy`. Etiquetar `v0.1.0` queda pendiente
como mejora futura.
