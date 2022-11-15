# When running the first time, comment out the following block. 
# Then run terraform init (confirm yes)\ terraform plan \ terraform apply. 
# After the apply is complete, uncomment the below block and run terraform init plan apply as before

# terraform {
#   backend "s3" {
#     bucket         = "bouquet-jckjk848402mcbckjbcs28884"
#     key            = "terraform.tfstate"
#     region         = "eu-west-1"
#     dynamodb_table = "terraform-state"
#   }
# }
