# Running Docker containers in AWS using Terraform
* The main idea:
* Build and push a Docker image into ECR using Codebuild
* Changes to Github automatically push a new image
* Use ECS to pull and run the Docker image in Fargate 

## Requirements to run
* AWS account and user
* Terraform and AWS installed
* Clone this repository
* Copy your Github OAuth token to ./modules/codebuild/variables: github_token block

## Deployment
* When running the first time, leave the block in backend.tf commented
* Then run terraform init \ terraform plan \ terraform apply
* After the apply is complete, uncomment the above block and run:
* terraform init (confirm yes)
* terraform plan
* terraform apply