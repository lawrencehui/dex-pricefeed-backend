provider "aws" {
  region = "eu-west-2"
  profile = "trex-lawrencehui"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}


### VPC and Networking Setup
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

### ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "trex-dev-terraform-ecs-cluster"
}

### Security Groups
resource "aws_security_group" "ecs" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 38271
    to_port     = 38271
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow external Postgres access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### Task Definition for Kafka
resource "aws_ecs_task_definition" "kafka" {
  family                   = "kafka-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "kafka"
      image     = "bitnami/kafka:latest"
      essential = true
      portMappings = [
        {
          containerPort = 9092
          hostPort      = 9092
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "KAFKA_BROKER_ID"
          value = "1"
        },
        {
          name  = "KAFKA_ZOOKEEPER_CONNECT"
          value = "zookeeper:2181"
        },
        {
          name  = "KAFKA_LISTENERS"
          value = "PLAINTEXT://0.0.0.0:9092"
        },
      ]
    }
  ])
}

### Task Definition for Node.js Containers
resource "aws_ecs_task_definition" "chainlink_pricefeed" {
  family                   = "chainlink-pricefeed-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "chainlink-pricefeed"
      image     = "058264122363.dkr.ecr.eu-west-2.amazonaws.com/trex/terraform/backend/chainlink_pricefeed:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "KAFKA_BROKER"
          value = "kafka:9092"
        },
        {
          name  = "PORT"
          value = "31008"
        },
        {
          name  = "ALCHEMY_API_KEY"
          value = "WxX2qcdOhnHVp9LdXZ_X8FWR3pqov_1i"
        },
        {
          name  = "UPDATE_INTERVAL_S"
          value = "5"
        },
        {
          name  = "TIMESCALE_DB_CONNECTION_URI"
          value = "postgres://tsdbadmin:pwgsdklb791ndv4w@o8uz1vb8s1.vv4hygjlcc.tsdb.cloud.timescale.com:38271/tsdb?sslmode=require"
        }
        {
          name  = "NODE_ENV"
          value = "production"
        },

      ]
    }
  ])
}

# resource "aws_ecs_task_definition" "ws_services" {
#   family                   = "ws-services-task"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = 512
#   memory                   = 1024
#   execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

#   container_definitions = jsonencode([
#     {
#       name      = "ws-services"
#       image     = "<your_aws_account_id>.dkr.ecr.eu-west-2.amazonaws.com/ws-services:latest"
#       essential = true
#       portMappings = [
#         {
#           containerPort = 3000
#           hostPort      = 3000
#           protocol      = "tcp"
#         }
#       ]
#       environment = [
#         {
#           name  = "KAFKA_BROKER"
#           value = "kafka:9092"
#         }
#       ]
#     }
#   ])
# }

### ECS Services
resource "aws_ecs_service" "kafka" {
  name            = "kafka-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.kafka.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.public.id]
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "chainlink_pricefeed" {
  name            = "chainlink-pricefeed-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.chainlink_pricefeed.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.public.id]
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
}

# resource "aws_ecs_service" "ws_services" {
#   name            = "ws-services-service"
#   cluster         = aws_ecs_cluster.main.id
#   task_definition = aws_ecs_task_definition.ws_services.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"
#   network_configuration {
#     subnets         = [aws_subnet.public.id]
#     security_groups = [aws_security_group.ecs.id]
#     assign_public_ip = true
#   }
# }

### IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}