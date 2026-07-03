### EKS CLUSTER — wrapper personalizado sobre terraform-aws-modules/eks/aws ###
# A diferencia de mod-aws-vpc (reimplementado desde recursos raw), este módulo no reescribe
# EKS desde cero: el motor real es el módulo público terraform-aws-modules/eks/aws. Este
# módulo expone únicamente el subconjunto de variables/outputs que necesitan mis labs, con
# mi convención de naming (project/environment) y tags.
#
# Pin a v21.x (no v20.x): v20 exige aws provider < 6.0.0, lo cual choca con mod-aws-vpc y
# mod-aws-iam-role, que ya usan aws ~> 6.47 — Terraform necesita una sola versión de
# provider para todo el árbol de módulos. v21 soporta aws provider 6.x. Los nombres de
# varias variables cambiaron en v21 (cluster_name -> name, cluster_version ->
# kubernetes_version, cluster_endpoint_* -> endpoint_*, cluster_addons -> addons) pero
# enable_irsa/oidc_provider_arn/oidc_provider siguen existiendo igual.

module "this" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.24"

  name               = local.cluster_name
  kubernetes_version = var.cluster_version

  endpoint_public_access       = true # Lab only — en prd usar private + VPN
  endpoint_private_access      = true
  endpoint_public_access_cidrs = [var.my_ip_cidr]

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

      # Sin public IP: ya lo garantiza la subnet EKS de mod-aws-vpc (no tiene
      # map_public_ip_on_launch) — no es un argumento válido en este nivel del objeto.

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

  # Sin esto (default false), el usuario/rol IAM que corre `terraform apply` NO recibe
  # un access entry con permisos sobre el cluster — ni la consola, ni kubectl, ni nuestros
  # propios provider "kubernetes"/"helm" (que se autentican como este mismo IAM user vía
  # `aws eks get-token`) podrían ver u operar objetos de Kubernetes.
  enable_cluster_creator_admin_permissions = true

  # Solo addons sin dependencia de IRSA — sin aws-ebs-csi-driver (el lab no usa PV)
  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true # crear el addon ANTES del node group — si no, los nodos
                             # arrancan sin el plugin de red listo y terminan "Unhealthy"
    }
  }

  tags = local.common_tags
}
