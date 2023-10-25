output "aws_lb_int_rpc_domain" {
  value = module.elb.aws_lb_int_rpc_domain
}

output "aws_lb_ext_rpc_domain" {
  value = module.elb.aws_lb_ext_rpc_domain
}

output "aws_lb_int_explorer_domain" {
  value = module.elb.aws_lb_int_explorer_domain
}

output "aws_lb_ext_explorer_domain" {
  value = module.elb.aws_lb_ext_explorer_domain
}

output "aws_lb_int_monitoring_domain" {
  value = module.elb.aws_lb_int_monitoring_domain
}

output "aws_lb_ext_monitoring_domain" {
  value = module.elb.aws_lb_ext_monitoring_domain
}

output "aws_lb_int_archival_domain" {
  value = module.elb.aws_lb_int_archival_domain
}

output "aws_lb_ext_geth_domain" {
  value = module.elb.aws_lb_ext_rpc_geth_domain
}

output "base_dn" {
  value = local.base_dn
}
output "base_id" {
  value = local.base_id
}

output "geth_private_ip" {
  value = var.geth_count > 0 ? module.ec2.geth_private_ips[0] : null
}

output "aws_availability_zones" {
  value = local.default_zones
}

output "base_ami" {
  value = var.base_ami
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "number_of_validators" {
  value = var.validator_count
}

output "number_of_rpcs" {
  value = var.rpc_count
}

output "number_of_archivals" {
  value = var.archival_count
}

output "number_of_relayer" {
  value = var.relayer_count
}

output "number_of_monitoring" {
  value = var.monitoring_count
}

output "number_of_block_explorer" {
  value = var.explorer_count
}
