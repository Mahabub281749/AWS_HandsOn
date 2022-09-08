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


# Creating group

resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/users/"
}

# Create single user

resource "aws_iam_user" "user" {
  name = "Oishe"
}

# Create Multiple user

resource "aws_iam_user" "example" {
  count = "${length(var.username)}"
  name = "${element(var.username,count.index)}"
  path = "/system/"
}


# add users to a group

resource "aws_iam_group_membership" "team" {
  name = "tf-testing-group-membership"
  
  users = [
    aws_iam_user.user.name,
    
  ]

  group = aws_iam_group.developers.name
}

