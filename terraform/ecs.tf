# # ecs.tf
# module "ecs" {
#   source = "terraform-aws-modules/ecs/aws"
#   version = "5.11.4"  # specify the version you want to use

#   cluster_name = "trex-backend-cluster"

#   cluster_configuration = {
#     execute_command_configuration = {
#       logging = "OVERRIDE"
#       log_configuration = {
#         cloud_watch_log_group_name = "/aws/ecs/trex-backend"
#       }
#     }
#   }

#   fargate_capacity_providers = {
#     FARGATE = {
#       default_capacity_provider_strategy = {
#         weight = 50
#       }
#     }
#     FARGATE_SPOT = {
#       default_capacity_provider_strategy = {
#         weight = 50
#       }
#     }
#   }

#   services = {
#     chainlink-pricefeed = {
#       cpu    = 512
#       memory = 1024

#       # Container definition(s)
#       container_definitions = {

#         chainlink-pricefeed = {
#           cpu       = 256
#           memory    = 512
#           essential = true
#           image     = "your-docker-image-url"
#           port_mappings = [
#             {
#               name          = "chainlink-pricefeed"
#               containerPort = 80
#               protocol      = "tcp"
#             }
#           ]

#           readonly_root_filesystem = false

#           log_configuration = {
#             logDriver = "awslogs"
#             options = {
#               "awslogs-group"         = "/aws/ecs/trex-backend/chainlink-pricefeed"
#               "awslogs-region"        = "eu-west-2"
#               "awslogs-stream-prefix" = "ecs"
#             }
#           }

#           environment = [
#             {
#               name  = "ENVIRONMENT"
#               value = "dev"
#             }
#           ]
#         }
#       }

#       service_connect_configuration = {
#         namespace = "trex-backend"
#         service = {
#           client_alias = {
#             port     = 80
#             dns_name = "chainlink-pricefeed"
#           }
#           port_name      = "chainlink-pricefeed"
#           discovery_name = "chainlink-pricefeed"
#         }
#       }

#       load_balancer = {
#         service = {
#           target_group_arn = "arn:aws:elasticloadbalancing:eu-west-2:1234567890:targetgroup/your-target-group"
#           container_name   = "chainlink-pricefeed"
#           container_port   = 80
#         }
#       }

#       subnet_ids = module.vpc.private_subnets
#       security_group_rules = {
#         alb_ingress = {
#           type                     = "ingress"
#           from_port                = 80
#           to_port                  = 80
#           protocol                 = "tcp"
#           description              = "Service port"
#           source_security_group_id = module.alb.security_group_id
#         }
#         egress_all = {
#           type        = "egress"
#           from_port   = 0
#           to_port     = 0
#           protocol    = "-1"
#           cidr_blocks = ["0.0.0.0/0"]
#         }
#       }
#     }
#   }

#   tags = {
#     Environment = "Development"
#     Project     = "TREX Backend"
#   }
# }

# # module "ecs_cluster" {
# #   source = "terraform-aws-modules/ecs/aws"
# #   version = "6.0.0"

# #   ecs_cluster_name = "trex-cluster"
# #   vpc_id           = module.vpc.vpc_id
# #   subnets          = module.vpc.private_subnets

# #   # cluster_name = "trex-cluster"
# #   # vpc_id = module.vpc.vpc_id
# #   # subnets = module.vpc.private_subnets
# #   # security_group_ids = [aws_security_group.ecs_sg.id]
# #   # fargate_capacity_providers = {
# #   #   FARGATE = {
# #   #     default_capacity_provider_strategy = {
# #   #       weight = 50
# #   #       base   = 20
# #   #     }
# #   #   }
# #   # }
# # }


# # resource "aws_ecs_task_definition" "trex_task" {
# #   family                   = "trex-task"
# #   network_mode             = "awsvpc"
# #   requires_compatibilities = ["FARGATE"]
# #   cpu                      = 256
# #   memory                   = 512

# #   container_definitions = jsonencode([
# #     {
# #       name      = "chainlink-pricefeed-container"
# #       image     = "<AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/<YOUR_ECR_REPOSITORY>:latest"
# #       cpu       = 256
# #       memory    = 512
# #       essential = true
# #       portMappings = [
# #         {
# #           containerPort = 31008
# #           hostPort      = 31008
# #           protocol      = "tcp"
# #         }
# #       ]
# #       environment = [
# #         {
# #           name  = "PORT"
# #           value = "31008"
# #         },
# #         {
# #           name  = "NODE_ENV"
# #           value = "production"
# #         },
# #         {
# #           name  = "TIMESCALEDB_URL"
# #           value = aws_db_instance.timescaledb.endpoint
# #         },
# #         {
# #           name  = "KAFKA_BROKER"
# #           value = aws_msk_cluster.kafka.bootstrap_brokers
# #         }
# #       ]

# #       logConfiguration = {
# #         logDriver = "awslogs"
# #         options = {
# #           "awslogs-group"         = "/ecs/chainlink-pricefeed"
# #           "awslogs-region"        = "eu-west-2"
# #           "awslogs-stream-prefix" = "ecs"
# #           "awslogs-create-group" = true
# #         }
# #       }
# #     }
# #   ])
# # }

# # resource "aws_ecs_service" "trex_service" {
# #   name            = "trex-service"
# #   cluster         = module.ecs_cluster.cluster_id
# #   task_definition = aws_ecs_task_definition.trex_task.arn
# #   desired_count   = 2
# #   launch_type     = "FARGATE"
# #   network_configuration {
# #     subnets = module.vpc.private_subnets
# #     security_groups = [aws_security_group.ecs_sg.id]
# #     assign_public_ip = true
# #   }
# # }