locals {
  network_type  = "edge"
  base_ami      = length(var.base_ami) > 0 ? var.base_ami : data.aws_ami.available.id
  base_dn       = format("%s.%s.%s.private", var.deployment_name, local.network_type, var.company_name)
  base_id       = format("%s-%s", var.deployment_name, local.network_type)
  default_zones = length(var.zones) > 0 ? var.zones : data.aws_availability_zones.available.names
}

module "dns" {
  source           = "./modules/dns"
  base_dn          = local.base_dn
  region           = var.region
  validator_count  = var.validator_count
  relayer_count    = var.relayer_count
  rpc_count        = var.rpc_count
  archival_count   = var.archival_count
  monitoring_count = var.monitoring_count
  explorer_count   = var.explorer_count
  geth_count       = var.geth_count
  route53_zone_id  = var.route53_zone_id
  deployment_name  = var.deployment_name

  devnet_id             = module.networking.devnet_id
  aws_lb_int_rpc_domain = module.elb.aws_lb_int_rpc_domain
  aws_lb_ext_rpc_domain = module.elb.aws_lb_ext_rpc_domain
  # rpc_internal_enabled  = var.rpc_internal_enabled
  rpc_external_enabled  = var.rpc_external_enabled
  # aws_lb_ext_rpc_geth_domain = module.elb.aws_lb_ext_rpc_geth_domain
  validator_private_ips  = module.ec2.validator_private_ips
  relayer_private_ips    = module.ec2.relayer_private_ips
  rpc_private_ips        = module.ec2.rpc_private_ips
  archival_private_ips   = module.ec2.archival_private_ips
  monitoring_private_ips = module.ec2.monitoring_private_ips
  explorer_private_ips   = module.ec2.explorer_private_ips
  geth_private_ips       = module.ec2.geth_private_ips
}

module "ebs" {
  source           = "./modules/ebs"
  zones            = local.default_zones
  node_storage     = var.node_storage
  validator_count  = var.validator_count
  relayer_count    = var.relayer_count
  rpc_count        = var.rpc_count
  archival_count   = var.archival_count
  monitoring_count = var.monitoring_count
  explorer_count   = var.explorer_count

  validator_instance_ids  = module.ec2.validator_instance_ids
  relayer_instance_ids    = module.ec2.relayer_instance_ids
  archival_instance_ids   = module.ec2.archival_instance_ids
  rpc_instance_ids        = module.ec2.rpc_instance_ids
  monitoring_instance_ids = module.ec2.monitoring_instance_ids
  explorer_instance_ids   = module.ec2.explorer_instance_ids
}

module "ec2" {
  source                   = "./modules/ec2"
  base_dn                  = local.base_dn
  base_ami                 = "ami-0c80cdf6d394d7135"
  geth_count               = var.geth_count
  geth_instance_type       = var.geth_instance_type
  validator_count          = var.validator_count
  validator_instance_type  = var.validator_instance_type
  relayer_count            = var.relayer_count
  relayer_instance_type    = var.relayer_instance_type
  rpc_count                = var.rpc_count
  rpc_instance_type        = var.rpc_instance_type
  archival_count           = var.archival_count
  archival_instance_type   = var.archival_instance_type
  monitoring_count         = var.monitoring_count
  monitoring_instance_type = var.monitoring_instance_type
  explorer_count           = var.explorer_count
  explorer_instance_type   = var.explorer_instance_type
  base_devnet_key_name     = format("%s_ssh_key", var.deployment_name)
  private_network_mode     = true
  network_type             = local.network_type
  deployment_name          = var.deployment_name
  create_ssh_key           = var.create_ssh_key
  devnet_key_value         = var.devnet_key_value

  devnet_private_subnet_ids = module.networking.devnet_private_subnet_ids
  devnet_public_subnet_ids  = module.networking.devnet_public_subnet_ids
  ec2_profile_name          = module.ssm.ec2_profile_name
}

module "elb" {
  source                      = "./modules/elb"
  # rpc_internal_enabled        = var.rpc_internal_enabled
  rpc_external_enabled        = var.rpc_external_enabled
  # explorer_internal_enabled   = var.explorer_internal_enabled
  explorer_external_enabled   = var.explorer_external_enabled
  # monitoring_internal_enabled = var.monitoring_internal_enabled
  monitoring_external_enabled = var.monitoring_external_enabled
  http_rpc_port               = var.http_rpc_port
  rootchain_rpc_port          = var.rootchain_rpc_port
  geth_count                  = var.geth_count
  rpc_count                   = var.rpc_count
  monitoring_count            = var.monitoring_count
  explorer_count              = var.explorer_count
  archival_count              = var.archival_count
  route53_zone_id             = var.route53_zone_id
  base_id                     = local.base_id

  devnet_private_subnet_ids   = module.networking.devnet_private_subnet_ids
  devnet_public_subnet_ids    = module.networking.devnet_public_subnet_ids
  validator_instance_ids      = module.ec2.validator_instance_ids
  rpc_instance_ids            = module.ec2.rpc_instance_ids
  explorer_instance_ids       = module.ec2.explorer_instance_ids
  monitoring_instance_ids     = module.ec2.monitoring_instance_ids
  archival_instance_ids       = module.ec2.archival_instance_ids
  relayer_instance_ids        = module.ec2.relayer_instance_ids
  geth_instance_ids           = module.ec2.geth_instance_ids
  devnet_id                   = module.networking.devnet_id
  security_group_open_http_id = module.securitygroups.security_group_open_http_id
  security_group_default_id   = module.securitygroups.security_group_default_id
  certificate_arn             = module.dns.certificate_arn
}

module "networking" {
  source           = "./modules/networking"
  base_dn          = local.base_dn
  devnet_vpc_block = var.devnet_vpc_block
  zones            = local.default_zones
}

module "securitygroups" {
  source = "./modules/securitygroups"
  depends_on = [
    module.networking
  ]
  network_type       = local.network_type
  deployment_name    = var.deployment_name
  network_acl        = var.network_acl
  http_rpc_port      = var.http_rpc_port
  rootchain_rpc_port = var.rootchain_rpc_port

  devnet_id                                = module.networking.devnet_id
  validator_primary_network_interface_ids  = module.ec2.validator_primary_network_interface_ids
  relayer_primary_network_interface_ids    = module.ec2.relayer_primary_network_interface_ids
  rpc_primary_network_interface_ids        = module.ec2.rpc_primary_network_interface_ids
  archival_primary_network_interface_ids   = module.ec2.archival_primary_network_interface_ids
  monitoring_primary_network_interface_ids = module.ec2.monitoring_primary_network_interface_ids
  explorer_primary_network_interface_ids   = module.ec2.explorer_primary_network_interface_ids
  geth_primary_network_interface_ids       = module.ec2.geth_primary_network_interface_ids
  geth_count                               = var.geth_count
  monitoring_count                         = var.monitoring_count
  explorer_count                           = var.explorer_count
}

module "ssm" {
  source          = "./modules/ssm"
  base_dn         = local.base_dn
  deployment_name = var.deployment_name
  network_type    = local.network_type
}
