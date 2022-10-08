# STEP 0

# STEP 1 VPC
output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "environment" {
  value = var.environment
}

# STEP 2 Subnets

output "publicSubnetCIDR" {
  value = var.publicSubnetCIDR
}

output "subnet_id" {
  value = aws_subnet.publicsubnet01.id
}

# STEP 3 Security Groups

output "vpc_security_group_ids" {
  value = aws_security_group.SecurityGroup_EC2inPublicSubnet
}

# STEP 4 EC2 Instances
