resource "aws_s3_bucket" "bouquet" {
  bucket = "bouquet-jckjk848402mcbckjbcs28884"
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.bouquet.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "bouquet02" {
    bucket = aws_s3_bucket.bouquet.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform-lock" {
    name           = "terraform-state"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
    tags = {
        "Name" = "DynamoDB Terraform State Lock Table"
    }
}


# Terraform IAM account will require the following S3 bucket permissions: 
resource "aws_iam_policy" "policy" {
  name        = "test_policy"
  path        = "/"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action = [ 
          "s3:ListBucket",
        ]  
        Resource = "arn:aws:s3:::bouquet-jckjk848402mcbckjbcs28884" # name goes here
      },
      {
        Effect   = "Allow",
        Action = [ 
            "s3:GetObject",
            "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::bouquet-jckjk848402mcbckjbcs28884" # name goes here
      }
    ]
  })
}

# Also add the following DynamoDB table permissions:

resource "aws_iam_policy" "policy2" {
  name        = "test_policy2"
  path        = "/"
  description = "My test policy2"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        Resource = "arn:aws:dynamodb:*:*:table/terraform-state" # name goes here
      }
    ]
  })  
}
