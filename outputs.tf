# Outputs that are currently not being used are commented

# STEP 0

output "region" {
  value = var.region
}

# STEP 1 VPC
output "vpc_id" {
 value = aws_vpc.my_vpc.id
}

#output "environment" {
#  value = var.environment
#}

# STEP 2 Subnets

# output "private_subnets" {
#   value = [aws_subnet.privatesubnet01.id, aws_subnet.privatesubnet02.id]
# }

#output "publicSubnetCIDR" {
#  value = var.publicSubnetCIDR
#}

#output "subnet_id" {
#  value = aws_subnet.publicsubnet01.id
#}

# STEP 3 Security Groups

#output "vpc_security_group_ids" {
#  value = aws_security_group.SecurityGroup_EC2inPublicSubnet
#}

# STEP 4 EC2 Instances

# Step 6: Application Load Balancer (ALB)

# output "alb_dns" {
#   value = aws_alb.this01.dns_name
# }

# output "alb_listener" {
#   value = aws_alb_listener.this03.id
# }
