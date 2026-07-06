### GLOBAL VARIABLES ###

variable "project" {
  description = "Project or application name (used for naming and tagging)"
  type        = string
  default     = "poc"
}

variable "environment" {
  description = "Logical environment (e.g. lab, nonproduction, production) used for tagging"
  type        = string
  default     = "nonproduction"
}

variable "tags" {
  description = "Additional tags merged with the default tags"
  type        = map(string)
  default     = {}
}

### NETWORKING ###

variable "vpc_id" {
  description = "VPC ID where the cluster and node group will be created"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the EKS cluster and managed node group (use dedicated EKS subnets, e.g. module.vpc.eks_subnets from mod-aws-vpc)"
  type        = list(string)
}

variable "my_ip_cidr" {
  description = "CIDR (your public IP, e.g. \"203.0.113.5/32\") allowed to reach the public EKS API endpoint"
  type        = string
}

### CLUSTER ###

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane"
  type        = string
  default     = "1.31"
}

### NODE GROUP ###

variable "node_instance_types" {
  description = "Instance types for the managed node group. t3.small soporta solo ~11 pods/nodo (límite de IPs del ENI, no de CPU/RAM) — insuficiente para correr ArgoCD + External Secrets + ALB Controller + kube-prometheus-stack a la vez. t3.medium (~17 pods/nodo) es el mínimo viable para este lab"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  description = "ON_DEMAND or SPOT — SPOT recommended for non-critical labs (~65% cheaper)"
  type        = string
  default     = "SPOT"
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 3
}

variable "node_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "node_disk_size" {
  description = "EBS root volume size (GiB) for each node"
  type        = number
  default     = 20
}
