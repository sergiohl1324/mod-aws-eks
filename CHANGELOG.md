# Changelog

## [0.1.3] - 2026-07-05
### Fixed
- Default `node_instance_types` de `t3.small` a `t3.medium`. `t3.small` tiene un límite de
  **~11 pods por nodo** (fórmula EKS: `ENIs × (IPs por ENI - 1) + 2`, ligado a IPs de ENI, no
  a CPU/memoria) — insuficiente para correr ArgoCD (7 pods) + External Secrets (3) + ALB
  Controller (2) + kube-prometheus-stack (varios) simultáneamente en 2 nodos. Causaba
  `FailedScheduling: Too many pods` y timeouts en `helm_release`. `t3.medium` sube el límite a
  ~17 pods/nodo (34 en total con 2 nodos).

## [0.1.2] - 2026-07-03
### Fixed
- `enable_cluster_creator_admin_permissions = true`: sin esto, el IAM user/role que corre
  `terraform apply` no recibe un access entry de EKS y no puede ver/operar objetos de
  Kubernetes (ni por consola, ni por kubectl, ni los `provider "kubernetes"`/`"helm"` del
  repo consumidor).
- `before_compute = true` en el addon `vpc-cni`: sin esto, el addon podía crearse después
  de que los nodos arrancaran, dejándolos sin el plugin de red listo a tiempo y causando
  `NodeCreationFailure: Unhealthy nodes in the kubernetes cluster`.

## [0.1.1] - 2026-07-03
### Fixed
- Upgrade `terraform-aws-modules/eks/aws` de `~> 20.31` a `~> 21.24`: v20 exige `aws` provider
  `< 6.0.0`, lo cual es incompatible con `mod-aws-vpc`/`mod-aws-iam-role` (ambos en `~> 6.47`),
  causando un conflicto de versiones irresoluble en `terraform init`.
- Renombradas las variables internas afectadas por el salto v20→v21 (`name`,
  `kubernetes_version`, `endpoint_public_access(_cidrs)`, `endpoint_private_access`,
  `addons`) — sin cambios en la interfaz pública de este módulo (`variables.tf`/`outputs.tf`
  no cambiaron).
- Eliminado `associate_public_ip_address` del node group (no es un argumento válido en ese
  nivel del objeto; la subnet EKS de `mod-aws-vpc` ya garantiza que no haya IP pública).

## [0.1.0] - 2026-07-03
### Added
- Initial release: wrapper personalizado sobre `terraform-aws-modules/eks/aws` (~> 20.31).
- Node group administrado con soporte Spot (`node_capacity_type`).
- `cluster_endpoint_public_access_cidrs` para restringir el API server público a una IP/CIDR específico.
- Addons base sin dependencia de IRSA: coredns, kube-proxy, vpc-cni.
- Outputs de OIDC (`oidc_provider_arn`, `oidc_provider`) listos para construir roles IRSA en el repo consumidor.
