variable "aws_profile" {
  description = "The AWS profile that we're going to use"
  type        = string
}

variable "company_name" {
  description = "The name of the company for this particular deployment"
  type        = string
}

variable "create_ssh_key" {
  description = "Should a new ssh key be created or should we use the devnet_key_value"
  type        = bool
  default     = true
}

variable "deployment_name" {
  description = "The unique name for this particular deployment"
  type        = string
}

variable "devnet_key_value" {
  description = "The public key value to use for the ssh key. Required when create_ssh_key is false"
  type        = string
  default     = ""
}

variable "devnet_vpc_block" {
  description = "The cidr block for our VPC"
  type        = string
}

variable "environment" {
  description = "The environment for deployment for this particular deployment"
  type        = string
}

variable "geth_count" {
  description = "The number of geth nodes that we're going to deploy"
  type        = number
  validation {
    condition = (
      var.geth_count == 0 || var.geth_count == 1
    )
    error_message = "There should only be 1 geth node, or none (if you are using another public L1 chain for bridge)."
  }
}

variable "http_rpc_port" {
  description = "The TCP port that will be used for http rpc"
  type        = number
}

variable "network_acl" {
  description = "Which CIDRs should be allowed to access the explorer and RPC"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_storage" {
  description = "The size of the storage disk attached to full nodes ,validators and rpcs "
  type        = number
}

variable "rootchain_rpc_port" {
  description = "The TCP port that will be used for rootchain (for bridge)"
  type        = number
  default     = 8545
}

variable "route53_zone_id" {
  description = "The ID of the hosted zone to contain the CNAME record to our LB"
  type        = string
  default     = ""
}

variable "owner" {
  description = "The main point of contact for this particular deployment"
  type        = string
}

variable "region" {
  description = "The region where we want to deploy"
  type        = string
}

variable "validator_count" {
  description = "The number of validators that we're going to deploy"
  type        = number
}

variable "relayer_count" {
  description = "The number of rpcs that we're going to deploy"
  type        = number
}

variable "rpc_count" {
  description = "The number of rpcs that we're going to deploy"
  type        = number
}

variable "archival_count" {
  description = "The number of archivals that we're going to deploy"
  type        = number
}

variable "monitoring_count" {
  description = "The number of monitoring that we're going to deploy"
  type        = number
}

variable "explorer_count" {
  description = "The number of explorer that we're going to deploy"
  type        = number
}
variable "zones" {
  description = "The availability zones for deployment"
  type        = list(string)
  default     = []
}

variable "base_ami" {
  description = "The availability zones for deployment"
  type        = string
}

variable "geth_instance_type" {
  description = "The type of geth instance that we're going to use"
  type        = string
}

variable "validator_instance_type" {
  description = "The type of validators instance that we're going to use"
  type        = string
}

variable "relayer_instance_type" {
  description = "The type of relayers instance that we're going to use"
  type        = string
}

variable "rpc_instance_type" {
  description = "The type of rpcs instance that we're going to use"
  type        = string
}

variable "archival_instance_type" {
  description = "The type of archivals instance that we're going to use"
  type        = string
}

variable "monitoring_instance_type" {
  description = "The type of monitorings instance that we're going to use"
  type        = string
}

variable "explorer_instance_type" {
  description = "The type of explorers instance that we're going to use"
  type        = string
}

# variable "rpc_internal_enabled" {
#   type = string
# }

variable "rpc_external_enabled" {
  type = string
}

# variable "explorer_internal_enabled" {
#   type = string
# }

variable "explorer_external_enabled" {
  type = string
}

# variable "monitoring_internal_enabled" {
#   type = string
# }

variable "monitoring_external_enabled" {
  type = string
}

