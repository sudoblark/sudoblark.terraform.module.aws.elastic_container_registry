terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.61.0"
    }
  }
  required_version = "~> 1.5.0"
}

provider "aws" {
  region = "eu-west-2"
}

module "elastic_container_registry" {
  source = "github.com/sudoblark/sudoblark.terraform.module.aws.elastic_container_registry?ref=1.0.0"

  application_name   = var.application_name
  environment        = var.environment
  raw_ecr_registries = local.raw_ecr_registries

}