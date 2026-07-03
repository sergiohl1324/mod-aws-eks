output "cluster_name" {
  description = "EKS cluster name"
  value       = module.this.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.this.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for the cluster (for kubeconfig)"
  value       = module.this.cluster_certificate_authority_data
}

output "cluster_version" {
  description = "Kubernetes version running on the control plane"
  value       = module.this.cluster_version
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider — usar como Federated principal en trust policies IRSA"
  value       = module.this.oidc_provider_arn
}

output "oidc_provider" {
  description = "OIDC provider issuer URL (sin el ARN) — usar para construir condiciones sub/aud en trust policies IRSA"
  value       = module.this.oidc_provider
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS control plane"
  value       = module.this.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group ID shared by the managed node group"
  value       = module.this.node_security_group_id
}
