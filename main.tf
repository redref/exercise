terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.1.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.6.3"
    }
  }
}

provider "sops" {}

data "sops_file" "aws_secret_key" {
  source_file = format("%s/%s", path.module, var.provider_aws_secret_key_sops_file)
  input_type  = "json"
}

# Configure the AWS Provider
provider "aws" {
  region     = var.region
  access_key = var.provider_aws_access_key
  secret_key = data.sops_file.aws_secret_key.data["aws_secret_key"]

  # Values for testing without credentials
  skip_credentials_validation = var.mock_aws
  skip_requesting_account_id  = var.mock_aws
  skip_metadata_api_check     = var.mock_aws
  s3_use_path_style           = var.mock_aws
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  count = tobool(var.mock_aws) ? 0 : 1
}

