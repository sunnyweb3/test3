#!/bin/bash

### Remove terraform cache
find . -type d -name ".terraform" -prune -exec rm -rf {} \;
find . -type f -name ".terraform.lock.hcl" -prune -exec rm -rf {} \;
# find . -type f -name "private.pem" -prune -exec rm -rf {} \;

### Terraform apply function
apply_terraform() {
    read -p "Did you update the variable values in backend.tf and $1 file? (y/n) " yn
    if [[ $yn == [yY] ]]; then
        ### Creating resources with Terraform
        terraform init
        terraform plan -var-file="$1" -out=tf.plan
        terraform show -no-color tf.plan > tfplan.txt
        printf "\n"
        echo "VERIFY THE OUTPUT OF TERRAFORM PLAN AT /terraform/tfplan.txt"
        printf "\n"
        read -p "Do you want to proceed with terraform apply? (y/n) " yn
        if [[ $yn == [yY] ]]; then
            echo "ok, terraform applying"
            terraform apply -var-file="$1" -auto-approve
            exit
        elif [[ $yn == [nN] ]]; then
            echo "exiting..."
            exit
        else
            echo "invalid response"
        fi
    fi
}

### Terraform state init
read -p "Do you want to init new terraform state? (y/n) " yn
if [[ $yn == [yY] ]]; then
    pushd terraform/state
    terraform init
    terraform plan -var-file="../dev.tfvars" -out=tf.plan
    terraform show -no-color tf.plan > tfplan.txt
    printf "\n"
    echo "VERIFY THE OUTPUT OF TERRAFORM PLAN AT /terraform/state/tfplan.txt"
    printf "\n"
    read -p "Do you want to proceed with terraform apply? (y/n) " yn
    if [[ $yn == [yY] ]]; then
        echo "ok, terraform applying"
				terraform apply -var-file="../dev.tfvars" -auto-approve
				popd
				pushd terraform
        apply_terraform "./dev.tfvars"
    elif [[ $yn == [nN] ]]; then
        echo "exiting..."
        exit
    else
        echo "invalid response"
    fi
elif [[ $yn == [nN] ]]; then
		popd
		pushd terraform
    apply_terraform "dev.tfvars"
    exit
else
    echo "invalid response"
fi
