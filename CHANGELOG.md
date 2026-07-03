# Changelog

## [0.1.0] - 2026-07-03
### Added
- Initial release: wrapper personalizado sobre `terraform-aws-modules/eks/aws` (~> 20.31).
- Node group administrado con soporte Spot (`node_capacity_type`).
- `cluster_endpoint_public_access_cidrs` para restringir el API server público a una IP/CIDR específico.
- Addons base sin dependencia de IRSA: coredns, kube-proxy, vpc-cni.
- Outputs de OIDC (`oidc_provider_arn`, `oidc_provider`) listos para construir roles IRSA en el repo consumidor.
