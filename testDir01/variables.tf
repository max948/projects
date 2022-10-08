# STEP 0

variable "region" {
  # The default region in which to deploy infrastructure
  type    = string
  default = "eu-west-1"
}

# STEP 1 VPC

variable "cidr" {
  default = "10.0.0.0/16"
}

variable "environment" {
  default = "dev"
}

# STEP 2 Subnets

variable "publicSubnetCIDR" {
  default = ["10.0.1.0/24"]
}

# STEP 3 Security Groups

variable "allowed_ports" {
  description = "List of allowed ports"
  type        = list(any)
  default     = ["80", "443", "22", "8080"]
}

# STEP 4 EC2 Instances

variable "instance_type" {
  # Default instance_type to deploy
  type    = string
  default = "t2.micro"
}
