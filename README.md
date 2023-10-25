# Deploy Polygon Edge
## Prerequisite
>[AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)  
[AWS Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)  
[Python](https://www.python.org/downloads/)  
[Boto3](https://pypi.org/project/boto3/)   
[botocore](https://pypi.org/project/botocore/)   
[Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)    
[Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

## Setup AWS Profile
Setup local aws profile with following command
```sh
aws configure --profile <name>
```

## Infrastructure Deployment with Terraform 
Make changes to the variable values in `terraform/<env>.tfvars`  

```yaml
...
###### Deployment Information ######
deployment_name = "hoandev"
owner           = "hoan@blockgen.studio"
company_name    = "blockgenstudio"

###### Backend Configure ######
environment         = "devnet"
bucket_name         = "terraform-state-hoan-test"
versioning_status   = "Enabled"
dynamodb_table_name = "terraform-state-lock"
aws_profile         = "bs-playground"
base_ami            = "ami-0957ce4ddf1bd8425"
node_storage        = 20
region              = "us-west-2"

###### Network Configure ######

...
```
### Set environment vartiable
```sh
AWS_CONFIG_FILE="~/.aws/credentials"      
AWS_PROFILE="<your-profile-name>"
AWS_REGION="<aws-region>"
```
### Deployment
Run the deployment script `terraform.sh` and follow the instructions for infrastructure deployment.

```sh
chmod +x terraform.sh
./terraform.sh
```
### Run terraform command
After the first time you run the deployment script. You can apply upcoming changes more easily by using the terraform command
```sh
cd terraform
terraform plan --var-file="dev.tfvars"
terraform apply --var-file="dev.tfvars" -auto-approve
```

## Applications Deployment (Ansible)
### Prerequisites
Make changes to the variable values in 
  - `ansible/inventory/aws_ec2` 
  - `ansible/group_vars/all`  
  - `ansible/local-extra-vars.yml`

Example:
```yaml
regions:
  - us-west-2

filters:
  tag:BaseDN: "bsdev.edge.blockgenstudio.private"
```

### Set environment vartiable
```sh
AWS_CONFIG_FILE="~/.aws/credentials"      
AWS_PROFILE="<your-profile-name>"
AWS_REGION="<aws-region>"
```

To configure prerequisites, run `ansible.sh`  
```sh
cd ansible
chmod +x ansible.sh
./ansible.sh
```

Check that you can ping all of the EC2. The result is expected as follows:  
```json
...
i-0300c63b6e2e8202f | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
...
```

#### Export the environment variables
```sh
export AWS_SHARED_CREDENTIALS_FILE="~/.aws/credentials"    
export AWS_PROFILE="bs-playground"
export AWS_REGION="us-west-2"
```

### Blockchain Deployment

### Prerequisites
  - Deploy a smart contract with custom token
### Bootstrap blockchain data
Make changes to the variable values in `ansible/local-extra-vars.yml` 

Place the Polygon Edge binary in the `/ansible/roles/edge-bootstrap/files` directory

Run edge bootstrap with following commands 

```sh
ansible-playbook --inventory inventory/aws_ec2.yml --extra-vars "@local-extra-vars.yml" edge-bootstrap.yml
```

In `ansible/output/deploy_output`, verify the output.  

#### Funding the validator/relayer nodes  
`MetaMask` is being used to fund some native and custom tokens to validator nodes.
#### Run finalize bootstrap  
```sh
ansible-playbook --inventory inventory/aws_ec2.yml --extra-vars "@local-extra-vars.yml" edge-finalize.yml
```

In `ansible/output/validator_output`, check the output

#### Transfer the bootstrap artifact to nodes 
Extract artifact `[BaseDN].tar.gz` folder on local machine
```sh
tar -xvf /tmp/[BaseDN].tar.gz -C /tmp/
```
Transfer the artifact to the nodes  
```sh
ansible-playbook --inventory inventory/aws_ec2.yml --extra-vars "@local-extra-vars.yml" edge-artifact.yml
```

#### Validating the chain is working
Verify edge service is running on validator nodes
```sh
systemctl status edge

root@validator-001:/var/snap/amazon-ssm-agent/6563# systemctl status edge
● edge.service - Polygon Edge Client
     Loaded: loaded (/etc/systemd/system/edge.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2023-10-16 10:33:06 UTC; 1min 28s ago
       Docs: https://github.com/0xPolygon/polygon-edge/
   Main PID: 11475 (polygon-edge)
      Tasks: 8 (limit: 2292)
     Memory: 27.3M (high: 1.3G max: 1.5G swap max: 0B available: 1.2G)
        CPU: 722ms
     CGroup: /system.slice/edge.service
             └─11475 polygon-edge server --data-dir /var/lib/edge --secrets-config /var/lib/edge/secret-config.jso>

Oct 16 10:33:06 validator-001.hoandev.edge.blockgenstudio.private systemd[1]: Started Polygon Edge Client.
```
check for logs on validator there shouldn't be any error
```sh
journalctl -u edge -f 
```

Make a erc-20 deposit using  below command, first deposit needs to be done to relayer node address
```sh
./polygon-edge bridge deposit-erc20 \
    --sender-key <hex_encoded_depositor_private_key> \
    --receivers <receivers_addresses> \
    --amounts <amounts> \
    --root-token <root_erc20_token_address> \
    --root-predicate <root_erc20_predicate_address> \
    --json-rpc <root_chain_json_rpc_endpoint>

[DEPOSIT ERC 20]
Sender                  = 0x16AC24F0aca282c70a63Fa43fFCe6c971807a008
Receivers               = 0xD07882E6797802FcaBaB558E0C98EBa2315F23ae
Amounts                 = 10000000000000000000
Inclusion Block Numbers = 41265119
```

Check the balance of the wallet on super net using below command
```sh
curl --location '<supernet_json_rpc_url>' \
--header 'Content-Type: application/json' \
--data '{"jsonrpc":"2.0","method":"eth_getBalance","params":["<receiver_address>", "latest"],"id":1}'
```
### Block Explorer
Run below command to setup block explorer  
```sh
ansible-playbook --inventory inventory/aws_ec2.yml --extra-vars "@local-extra-vars.yml" explorer.yml
```

### Monitoring Deployment
#### Deploy monitoring system 
```sh
ansible-playbook --inventory inventory/aws_ec2.yml --extra-vars "@local-extra-vars.yml" observability.yml
```
  
#### Setup AWS profile for CloudWatch exporter

The CloudWatch Exporter uses the AWS Java SDK, which offers a variety of ways to provide credentials. This includes the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.

The `cloudwatch:ListMetrics`, `cloudwatch:GetMetricStatistics` and `cloudwatch:GetMetricData` IAM permissions are required. The `tag:GetResources` IAM permission is also required to use the `aws_tag_select` feature.

Run following command to setup aws profile
```sh
aws ssm start-session --target [monitoring-instance-id]
sudo su
aws configure
```

#### Configure Alert
Make changes to the variable values in `ansible/roles/prometheus/alertmanager.yml`.  
About Telegram:
```
bot_token: Telegram Bot ID
chat_id: Group chat ID
```
See how to get telegram ID and group chat ID [here](https://gist.github.com/hoanlac9/cfdd56b172cc31145996919dacd6443b)  

About Slack: ...

Make changes to the grafana dashboard url values in `ansible/roles/prometheus/template.tmpl`.  

## Infrastructure Destroy (Terraform)
Run below command to destroy the infrastructure

```sh
cd terraform
terraform destroy -var-file="[env].tfvars" -auto-approve
```
