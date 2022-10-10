# version: working on this during weekend of 08.10.2022
# Questions have #? before them. OLD: shows what the previous code was
# To disable NAT, comment or uncomment near "NAT RELATED" comments.

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
    #? Is this funky syntax needed in the name? Name = "${var.environment}-vpc"
  }
}

# STEP 2 Subnets

data "aws_availability_zones" "availableAZ" {}

# Public Subnet 01
resource "aws_subnet" "publicsubnet01" {
  cidr_block              = var.publicSubnetCIDR # Refers to the variables.tf file
  # OLD: cidr_block              = "10.0.1.0/24" # Hardcoded this
  # default = ["10.0.1.0/24"]
  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = var.az_1
  # OLD: availability_zone       = "eu-west-1a" # Hardcoded this

  tags = {
    Name        = "dev-publicsubnet-01"
    AZ          = var.az_1
    # OLD: AZ          = "eu-west-1a" # Hardcoded this
    Environment = "${var.environment}-publicsubnet"
  }
}

# Public Subnet 02
resource "aws_subnet" "publicsubnet02" {
  cidr_block              = var.publicSubnetCIDR_3
  # OLD: cidr_block              = "10.0.3.0/24" # Hardcoded this
  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = var.az_2
  # OLD: availability_zone       = "eu-west-1b" # Hardcoded this

  tags = {
    Name        = "dev-publicsubnet-02"
    AZ          = var.az_2
    Environment = "${var.environment}-publicsubnet"
  }
}


# Private Subnet 01
resource "aws_subnet" "privatesubnet01" {
  cidr_block              = var.privateSubnetCIDR_2
  # OLD: cidr_block              = "10.0.2.0/24" # Hardcoded this
  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = var.az_1
  # OLD: availability_zone       = "eu-west-1a" # Hardcoded this

  tags = {
    Name        = "dev-privatesubnet-01"
    AZ          = var.az_1
    Environment = "${var.environment}-privatesubnet"
  }
}

# Private Subnet 02
resource "aws_subnet" "privatesubnet02" {
  cidr_block              = var.privateSubnetCIDR_4
  # OLD : cidr_block              = "10.0.4.0/24" # Hardcoded this
  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = var.az_2
  # OLD: availability_zone       = "eu-west-1b" # Hardcoded this

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
#? How to enable SSH in addition to tcp?
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


