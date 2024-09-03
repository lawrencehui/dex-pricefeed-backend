# # networking.tf
# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "3.14.2"
  
#   name            = "trex-vpc"
#   cidr            = var.vpc_cidr

#   azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
#   private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

#   enable_nat_gateway = true
#   single_nat_gateway = true

#   tags = {
#     Terraform = "true"
#     Environment = "dev"
#   }
# }

