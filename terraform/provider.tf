# # provider.tf
# provider "aws" {
#   region = var.aws_region
#   profile = "trex-lawrencehui"
# }

# terraform {

#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 4.16"
#     }
#   }
#   required_version = ">= 1.2.0"
#   # backend "s3" {
#   #   bucket = "trex-terraform-state-bucket"
#   #   key    = "trex_backend_monorepo/terraform.tfstate"
#   #   region = "eu-west-2"
#   # }
# }

