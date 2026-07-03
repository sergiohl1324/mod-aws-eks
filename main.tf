### EKS CLUSTER — wrapper personalizado sobre terraform-aws-modules/eks/aws ###
# A diferencia de mod-aws-vpc (reimplementado desde recursos raw), este módulo no reescribe
# EKS desde cero: el motor real es el módulo público terraform-aws-modules/eks/aws. Este
# módulo expone únicamente el subconjunto de variables/outputs que necesitan mis labs, con
# mi convención de naming (project/environment) y tags.

module "this" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access       = true # Lab only — en prd usar private + VPN
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = [var.my_ip_cidr]

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  eks_managed_node_groups = {
    main = {
      instance_types = var.node_instance_types
      capacity_type  = var.node_capacity_type
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      desired_size   = var.node_desired_size
      disk_size      = var.node_disk_size

      associate_public_ip_address = false

      labels = {
        role = "general"
      }
    }
  }

  # IRSA — este módulo solo habilita el OIDC provider. Los roles IRSA de cada addon
  # (ALB Controller, External Secrets, etc.) se crean en el repo consumidor con
  # mod-aws-iam-role, para evitar la dependencia circular de crearlos aquí adentro
  # (necesitarían el output de este módulo antes de que este módulo termine de existir).
  enable_irsa = true

  # Solo addons sin dependencia de IRSA — sin aws-ebs-csi-driver (el lab no usa PV)
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  tags = local.common_tags
}
