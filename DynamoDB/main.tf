terraform {
  required_version = ">=1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.29.0"
    }
  }
}

provider "aws" {
  region     = "eu-central-1"
  access_key = ""
  secret_key = ""
}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "DemoTable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "UserId"

  attribute {
    name = "UserId"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}

resource "aws_dynamodb_table_item" "item1" {
  table_name = aws_dynamodb_table.basic-dynamodb-table.name
  hash_key   = aws_dynamodb_table.basic-dynamodb-table.hash_key

  item = <<ITEM
{
  "UserId": {"S": "123456"},
  "first_name": {"S": "Mahabub"},
  "last_name": {"S": "Hasan"}
}
ITEM
}

resource "aws_dynamodb_table_item" "item2" {
  table_name = aws_dynamodb_table.basic-dynamodb-table.name
  hash_key   = aws_dynamodb_table.basic-dynamodb-table.hash_key

  item = <<ITEM
{
  "UserId": {"S": "0000"},
  "last_name": {"S": "Hasan"}
}
ITEM
}

