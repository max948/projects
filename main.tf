# Notes: 
# Version 18: Final
# WARNING: ensure modules/codebuild/variables github_token is not uploaded or shared
# Search "Replace image with image pushed by Codebuild" to update ECS image

# STEP 0

provider "aws" {
  # Refers to the variables.tf file
  region = var.region
}

# STEP 1 VPC

resource "aws_vpc" "my_vpc" {
  # Refers to the variables.tf file
  cidr_block       = var.cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.environment}-vpc"
  }
}

# STEP 2 Subnets

data "aws_availability_zones" "availableAZ" {}

# Public Subnet 01
resource "aws_subnet" "publicsubnet01" {
  cidr_block              = var.publicSubnetCIDR # Refers to the variables.tf file
  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = var.az_1

  tags = {
    Name        = "dev-publicsubnet-01"
    AZ          = var.az_1
    Environment = "${var.environment}-publicsubnet"
  }
}

# Public Subnet 02
resource "aws_subnet" "publicsubnet02" {
  cidr_block              = var.publicSubnetCIDR_3
  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = var.az_2

  tags = {
    Name        = "dev-publicsubnet-02"
    AZ          = var.az_2
    Environment = "${var.environment}-publicsubnet"
  }
}


# Private Subnet 01
resource "aws_subnet" "privatesubnet01" {
  cidr_block              = var.privateSubnetCIDR_2
  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = var.az_1

  tags = {
    Name        = "dev-privatesubnet-01"
    AZ          = var.az_1
    Environment = "${var.environment}-privatesubnet"
  }
}

# Private Subnet 02
resource "aws_subnet" "privatesubnet02" {
  cidr_block              = var.privateSubnetCIDR_4
  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = var.az_2

  tags = {
    Name        = "dev-privatesubnet-02"
    AZ          = var.az_2
    Environment = "${var.environment}-privatesubnet"
  }
}

# To provide internet in/out access for the VPC

resource "aws_internet_gateway" "internetgateway" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.environment}-InternetGateway"
  }
}

# "resource "aws_route_table"" is  needed to define the Public Routes

resource "aws_route_table" "publicroutetable" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internetgateway.id
  }
  tags = {
    Name = "${var.environment}-publicroutetable"
  }
  depends_on = [aws_internet_gateway.internetgateway]
}

# Custom route table
# Note that the default route, mapping the VPC's CIDR block to "local", is created implicitly and cannot be specified.

resource "aws_route_table" "privateroutetable" {
  vpc_id = aws_vpc.my_vpc.id
  #route = [] #original
  # NAT RELATED: uncomment the above line, and comment the route {} block below to disable NAT for testing
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_01.id
  }
  tags = {
    Name = "${var.environment}-privateroutetable"
  }
}

# Route Table Association - Public Routes

resource "aws_route_table_association" "routeTableAssociationPublicRoute" {
  route_table_id = aws_route_table.publicroutetable.id
  subnet_id      = aws_subnet.publicsubnet01.id
  depends_on = [aws_subnet.publicsubnet01, aws_route_table.publicroutetable]
}

# Associate public 02
resource "aws_route_table_association" "Public02" {
  route_table_id = aws_route_table.publicroutetable.id 
  subnet_id      = aws_subnet.publicsubnet02.id
}

# Now, associate the two private subnets to the private route table in the same way.
resource "aws_route_table_association" "Private01" {
  route_table_id = aws_route_table.privateroutetable.id
  subnet_id      = aws_subnet.privatesubnet01.id
}

resource "aws_route_table_association" "Private02" {
  route_table_id = aws_route_table.privateroutetable.id
  subnet_id      = aws_subnet.privatesubnet02.id
}

# STEP 3 Security Groups

resource "aws_security_group" "SecurityGroup_EC2inPublicSubnet" {
  name = "Security Group for EC2 instances public subnets"
  vpc_id = aws_vpc.my_vpc.id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-publicsubnetEC2-SG"
  }
}

# STEP 4 EC2 Instances

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "Public_Linux_01" {

  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.publicsubnet01.id
  vpc_security_group_ids = [aws_security_group.SecurityGroup_EC2inPublicSubnet.id]

  user_data = file("./install_apache.sh")

  tags = {
    Name = "My Amazon Linux Server Public 01"
  }
}

resource "aws_instance" "Public_Linux_02" {

  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.publicsubnet02.id
  vpc_security_group_ids = [aws_security_group.SecurityGroup_EC2inPublicSubnet.id]
  user_data = file("./install_apache.sh")

  tags = {
    Name = "My Amazon Linux Server Public 02"
  }
}

resource "aws_instance" "Private_Linux_01" {

  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.privatesubnet01.id
  vpc_security_group_ids = [aws_security_group.SecurityGroup_EC2inPublicSubnet.id]

  user_data = file("./install_apache.sh")

  tags = {
    Name = "My Amazon Linux Server Private 01"
  }
}

resource "aws_instance" "Private_Linux_02" {

  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.privatesubnet02.id
  vpc_security_group_ids = [aws_security_group.SecurityGroup_EC2inPublicSubnet.id]

  user_data = file("./install_apache.sh")

  tags = {
    Name = "My Amazon Linux Server Private 02"
  }
}

#########################
# Step 5: NAT Gateway

# First create an EIP, then a NAT, which depends on the IG.
# NAT RELATED: comment this entire step to disable NAT for testing purposes
# Create elastic IP address

resource "aws_eip" "eip01" {
  vpc      = true

  tags = {
    Name = "eip01"
  }

  depends_on = [aws_internet_gateway.internetgateway]
}

resource "aws_nat_gateway" "nat_gateway_01" {
  allocation_id = aws_eip.eip01.id
  subnet_id     = aws_subnet.publicsubnet01.id

  tags = {
    Name = "gw NAT"
  }
  depends_on = [aws_internet_gateway.internetgateway]
}

#########################
# Step 6: Application Load Balancer (ALB)

resource "aws_alb" "this01" {
  name    = "ALB"
  subnets = [aws_subnet.publicsubnet01.id, aws_subnet.publicsubnet02.id]
}

resource "aws_alb_target_group" "this02" {
  name        = "targetGroup"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id

  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

# Redirect traffic from ALB to TG
resource "aws_alb_listener" "this03" {
  load_balancer_arn = aws_alb.this01.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.this02.id
    type             = "forward"
  }
}

#########################
# Step 7: S3 bucket storage of the remote state

module "s3" {
  source = "./modules/s3"
}

#########################
# Step 8: ECR and ECS

# Create repository in ECR
resource "aws_ecr_repository" "repo01" {
  name = "simpleapp-dev"
}

# Create cluster in ECS
resource "aws_ecs_cluster" "cluster01" {
  name = "cluster01"
}

# Create ECS Service
resource "aws_ecs_service" "service01" {
  name                 = "service01"
  cluster              = aws_ecs_cluster.cluster01.id
  task_definition      = aws_ecs_task_definition.def01.id
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true
  network_configuration {
    subnets          = [aws_subnet.privatesubnet01.id, aws_subnet.privatesubnet02.id]
    assign_public_ip = true
  }
  depends_on = [ 
    aws_alb_listener.this03, aws_iam_role.role01
  ]
}

# Create ECS Task
resource "aws_ecs_task_definition" "def01" {
  family                   = "task_definition_name"
  execution_role_arn       = aws_iam_role.role01.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  container_definitions = jsonencode([
    {
      name = "task01"
      image = "880763692340.dkr.ecr.eu-west-1.amazonaws.com/simpleapp-dev:7f62de8c0c702acd1a24692bb4ab2f1fcfc45342-dev" #
      # Replace image with image pushed by Codebuild
      # e.g. 880763692340.dkr.ecr.eu-west-1.amazonaws.com/simpleapp-dev:96f269930272cea3e40bbbba5b9169905e86dddd-dev
      # 880763692340.dkr.ecr.eu-west-1.amazonaws.com/simpleapp-dev:66881965ba0a6dd698fa26e59e04ca56507478b0-dev
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort = 80
        }
      ]
    }
  ])
}

# Create IAM role for ECS
resource "aws_iam_role" "role01" {
  name = "role01"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "IAM role for ECS"
  }
}


resource "aws_iam_role_policy" "policy03" {
  role = aws_iam_role.role01.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe",
        "ec2:DescribeInstances"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ],
      "Resource": [
        "arn:aws:ssm:*:*:parameter/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:secretsmanager:*:*:secret:*"
      ]
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
         "kms:ListKeys",
         "kms:ListAliases",
         "kms:Describe*",
         "kms:Decrypt"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

#########################
# Step 9: Codebuild

module "codebuild" {
  source = "./modules/codebuild"
  vpc_id = aws_vpc.my_vpc.id
  private_subnets = [aws_subnet.privatesubnet01.id, aws_subnet.privatesubnet02.id]
  region = var.region
}
