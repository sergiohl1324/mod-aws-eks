### NAMING ###

locals {
  cluster_name = "${var.project}-eks-${var.environment}"
}

### TAGS ###

locals {
  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}
