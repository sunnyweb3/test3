###### Deployment Information ######
deployment_name = "tfdev"
owner           = "hoan@blockgen.studio"
company_name    = "blockgenstudio"

###### Backend Configure ######
environment         = "devnet"
bucket_name         = "terraform-state-tf-deploy"
versioning_status   = "Enabled"
dynamodb_table_name = "terraform-state-tf-deploy"
aws_profile         = "tf-deploy"
base_ami            = "ami-0957ce4ddf1bd8425"
node_storage        = 20
region              = "us-west-2"

###### Network Configure ######
devnet_vpc_block   = "10.10.0.0/16"
http_rpc_port      = "10002"
rootchain_rpc_port = "8545"

###### Explorer Nodes Configure ######
explorer_count            = 1
explorer_instance_type    = "t3.medium"
# explorer_internal_enabled = false
explorer_external_enabled = true

###### Geth Nodes Configure ######
geth_count         = 0
geth_instance_type = "t3.medium"

###### Monitoring Nodes Configure ######
monitoring_count            = 1
monitoring_instance_type    = "t3.medium"
# monitoring_internal_enabled = false
monitoring_external_enabled = true

###### RPC Nodes Configure ######
rpc_count            = 1
rpc_instance_type    = "t3.medium"
# rpc_internal_enabled = false
rpc_external_enabled = true

###### Archival Nodes Configure ######
archival_count         = 1
archival_instance_type = "t3.medium"

###### Relayer Nodes Configure ######
relayer_count         = 1
relayer_instance_type = "t3.medium"

###### Validator Nodes Configure ######
validator_count         = 3
validator_instance_type = "t3.medium"
