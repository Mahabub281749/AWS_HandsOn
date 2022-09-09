terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.29.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
 }

# Create single user

resource "aws_iam_user" "user" {
  name = "Rasel"
}

resource "aws_iam_access_key" "user" {
  user    = aws_iam_user.user.name
  
}

output "secret" {
  value = aws_iam_access_key.user.encrypted_secret
}


output "aws_iam_smtp_password_v4" {
  value = aws_iam_access_key.user.ses_smtp_password_v4
  sensitive = true
}

resource "aws_iam_policy" "policy" {
  name        = "test2_policy"
  path        = "/"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
})
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  users      = [aws_iam_user.user.name]
  policy_arn = aws_iam_policy.policy.arn
}