# STEP 0
## Please enter the default region here

variable "region" {
  # The default region in which to deploy infrastructure
  type    = string
  default = "eu-west-1"
}

variable "az_1" {
  # The default first availability zone in which to deploy infrastructure
  type    = string
  default = "eu-west-1a"
}

variable "az_2" {
  # The default second availability zone in which to deploy infrastructure
  type    = string
  default = "eu-west-1b"
}


# STEP 1 VPC
## Please enter the default CIDR block here
variable "cidr" {
  default = "10.0.0.0/16"
}

## Please enter the default environment here e.g. test, dev, prod
variable "environment" {
  default = "dev"
}

# STEP 2 Subnets
## Please enter what CIDR blocks you desire below

variable "publicSubnetCIDR" {
  type    = string # Added this
  # OLD: default = ["10.0.1.0/24"]
  default = "10.0.1.0/24"
}

variable "publicSubnetCIDR_3" {
  type    = string
  default = "10.0.3.0/24"
}

variable "privateSubnetCIDR_2" {
  type    = string
  default = "10.0.2.0/24"
}

variable "privateSubnetCIDR_4" {
  type    = string
  default = "10.0.4.0/24"
}

# STEP 3 Security Groups
# Please enter which allowed ports below you would like to be open

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


# Please enter which SSH key should be used to connect to your instances
variable "key_name" {
  description = "Name of key pair to to be used for SSH"
  default     = "key"
}
