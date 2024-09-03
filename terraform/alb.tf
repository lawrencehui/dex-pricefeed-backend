# module "alb" {
#   source  = "terraform-aws-modules/alb/aws"
#   version = "8.0.0"

#   name               = "trex-alb"
#   load_balancer_type = "application"

#   vpc_id             = module.vpc.vpc_id
#   subnets            = module.vpc.public_subnets
#   security_groups    = [module.alb_security_group.this_security_group_id]

#   http_tcp_listeners = [{
#     port     = 80
#     protocol = "HTTP"
#   }]

#   https_listeners = [{
#     port     = 443
#     protocol = "HTTPS"
#     ssl_policy = "ELBSecurityPolicy-2016-08"
#     certificate_arn = "your-cert-arn"
#   }]

#   target_groups = [{
#     name       = "ecs-tg"
#     backend_protocol = "HTTP"
#     port       = 80
#     target_type = "ip"
#     vpc_id     = module.vpc.vpc_id
#   }]

#   tags = {
#     Terraform = "true"
#     Environment = "dev"
#   }
# }