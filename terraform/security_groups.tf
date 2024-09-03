# # # security_groups.tf
# module "alb_security_group" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "4.0.0"

#   name        = "alb-sg"
#   description = "Security group for ALB"
#   vpc_id      = module.vpc.vpc_id

#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 80
#       to_port     = 80
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#     },
#     {
#       from_port   = 443
#       to_port     = 443
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#     },
#   ]

#   egress_with_cidr_blocks = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#     },
#   ]
# }

# module "ecs_security_group" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "4.0.0"

#   name        = "ecs-sg"
#   description = "Security group for ECS"
#   vpc_id      = module.vpc.vpc_id

#   ingress_with_source_security_group_id = [
#     {
#       from_port                = 80
#       to_port                  = 80
#       protocol                 = "tcp"
#       source_security_group_id = module.alb_security_group.this_security_group_id
#     },
#   ]

#   egress_with_cidr_blocks = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#     },
#   ]
# }

# module "rds_security_group" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "4.0.0"

#   name        = "rds-sg"
#   description = "Security group for RDS"
#   vpc_id      = module.vpc.vpc_id

#   ingress_with_source_security_group_id = [
#     {
#       from_port                = 5432
#       to_port                  = 5432
#       protocol                 = "tcp"
#       source_security_group_id = module.ecs_security_group.this_security_group_id
#     },
#   ]

#   egress_with_cidr_blocks = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#     },
#   ]
# }

# module "kafka_security_group" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "4.0.0"

#   name        = "kafka-sg"
#   description = "Security group for Kafka"
#   vpc_id      = module.vpc.vpc_id

#   ingress_with_source_security_group_id = [
#     {
#       from_port                = 9092
#       to_port                  = 9092
#       protocol                 = "tcp"
#       cidr_blocks              = ["10.0.0.0/16"] 
#       # source_security_group_id = module.ecs_security_group.this_security_group_id
#     },
#   ]

#   egress_with_cidr_blocks = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#     },
#   ]
# }



# # resource "aws_security_group" "ecs_sg" {
# #   name        = "ecs-security-group"
# #   description = "Allow HTTP inbound traffic to ECS service"
# #   vpc_id      = module.vpc.vpc_id

# #   ingress {
# #     from_port   = 0
# #     to_port     = 0
# #     protocol    = "-1"
# #     cidr_blocks = ["0.0.0.0/0"]
# #   }

# #   egress {
# #     from_port   = 0
# #     to_port     = 0
# #     protocol    = "-1"
# #     cidr_blocks = ["0.0.0.0/0"]
# #   }

# #   tags = {
# #     Name = "ecs-security-group"
# #   }
# # }

# # resource "aws_security_group" "rds_sg" {
# #   name        = "rds-security-group"
# #   vpc_id      = module.vpc.vpc_id

# #   ingress {
# #     from_port   = 5432
# #     to_port     = 5432
# #     protocol    = "tcp"
# #     cidr_blocks = module.vpc.private_subnets
# #   }

# #   egress {
# #     from_port   = 0
# #     to_port     = 0
# #     protocol    = "-1"
# #     cidr_blocks = ["0.0.0.0/0"]
# #   }

# #   tags = {
# #     Name = "rds-security-group"
# #   }
# # }

# # resource "aws_security_group" "kafka_sg" {
# #   name        = "kafka-security-group"
# #   vpc_id      = module.vpc.vpc_id

# #   ingress {
# #     from_port   = 9092
# #     to_port     = 9092
# #     protocol    = "tcp"
# #     cidr_blocks = module.vpc.private_subnets
# #   }

# #   egress {
# #     from_port   = 0
# #     to_port     = 0
# #     protocol    = "-1"
# #     cidr_blocks = ["0.0.0.0/0"]
# #   }

# #   tags = {
# #     Name = "kafka-security-group"
# #   }
# # }