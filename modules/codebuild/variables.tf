variable "vpc_id" {}
variable "private_subnets" {}

# WARNING: DO NOT UPLOAD THE BELOW TO GIT
variable "github_token" {
    default = ""
#    default = ""
}

variable "region" {}
variable "buildspec" {
  default = "buildspec.yml"
}
