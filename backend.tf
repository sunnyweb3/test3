terraform {
  backend "s3" {
    bucket         = "terraform-state-tf-deploy"
    key            = "state/bsdev"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-tf-deploy"
    profile        = "tf-deploy"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.1"
    }
    random = {
      source = "hashicorp/random"
      version = "3.5.1"
    }
  }
  required_version = ">= 1.4.0"
}
