provider "aws" {
  region                   = var.region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = var.aws_profile
  default_tags {
    tags = {
      Environment    = var.environment
      Network        = local.network_type
      Owner          = var.owner
      DeploymentName = var.deployment_name
      BaseDN         = local.base_dn
      Name           = local.base_dn
    }
  }
}
