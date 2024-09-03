# # # outputs.tf
# # output "ecs_cluster_id" {
# #   value = module.ecs_cluster.cluster_id
# # }

# # output "timescaledb_endpoint" {
# #   value = aws_db_instance.timescaledb.endpoint
# # }

# # output "kafka_broker_endpoints" {
# #   value = aws_msk_cluster.kafka.bootstrap_brokers_tls
# # }

# # Output relevant information
# output "vpc_id" {
#   value = module.vpc.vpc_id
# }

# output "private_subnets" {
#   value = module.vpc.private_subnets
# }

# output "public_subnets" {
#   value = module.vpc.public_subnets
# }

# output "alb_dns_name" {
#   value = module.alb.this_lb_dns_name
# }

# output "ecs_cluster_id" {
#   value = module.ecs_cluster.cluster_id
# }

# output "rds_endpoint" {
#   value = module.rds.endpoint
# }

# output "kafka_brokers" {
#   value = module.kafka.zookeeper_connect_string
# }