# # main.tf

# # Load networking module
# module "network" {
#   source = "./modules/network"

#   # Pass in variables as needed
#   vpc_cidr        = "10.0.0.0/16"
#   public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
#   enable_nat_gateway = true
#   single_nat_gateway = true

#   tags = {
#     Environment = "production"
#     Terraform   = "true"
#   }
# }

# # Security Groups for ECS, RDS (TimescaleDB), and Kafka
# module "security_groups" {
#   source = "./security_groups"

#   vpc_id = module.network.vpc_id
# }

# # ECS Cluster and Service setup
# module "ecs_service" {
#   source = "./modules/ecs_service"

#   vpc_id             = module.network.vpc_id
#   subnets            = module.network.private_subnets
#   security_group_ids = [module.security_groups.ecs_sg_id]

#   image_url          = "<AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/<YOUR_ECR_REPOSITORY>:latest"
#   container_port     = 31008
#   desired_count      = 2

#   environment = {
#     NODE_ENV        = "production"
#     TIMESCALEDB_URL = module.timescaledb.endpoint
#     KAFKA_BROKER    = module.kafka.broker_endpoints
#   }
# }

# # TimescaleDB setup in RDS
# module "timescaledb" {
#   source = "./modules/timescaledb"

#   vpc_id             = module.network.vpc_id
#   subnets            = module.network.private_subnets
#   security_group_ids = [module.security_groups.rds_sg_id]

#   db_name            = "trexdb"
#   db_username        = "admin"
#   db_password        = var.db_password
#   db_instance_class  = "db.t3.micro"
#   db_allocated_storage = 20
# }

# # # Kafka setup in MSK
# # module "kafka" {
# #   source = "./modules/kafka"

# #   vpc_id             = module.network.vpc_id
# #   subnets            = module.network.private_subnets
# #   security_group_ids = [module.security_groups.kafka_sg_id]

# #   kafka_cluster_name = "trex-kafka-cluster"
# #   kafka_version      = "2.8.0"
# #   broker_instance_type = "kafka.m5.large"
# #   broker_count       = 3
# #   ebs_volume_size    = 1000
# # }

