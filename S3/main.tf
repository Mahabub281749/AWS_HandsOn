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
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}

resource "aws_s3_bucket" "terraformbucket1234b" {
  bucket = "terraformbucket1234b"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "public_reads" {
  bucket = aws_s3_bucket.terraformbucket1234b.id
  acl    = "public-read"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.terraformbucket1234b.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.terraformbucket1234b.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : "arn:aws:s3:::terraformbucket1234b/*",
        "Principal" : "*"
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.terraformbucket1234b.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.terraformbucket1234b.id
  key    = "index.html"
  source = "Website/index.html"
  etag         = filemd5("Website/index.html")
  content_type = "text/html"
}

resource "aws_s3_object" "object2" {
  bucket = aws_s3_bucket.terraformbucket1234b.id
  key    = "beach.jpg"
  source = "Website/beach.jpg"
  etag         = filemd5("Website/beach.jpg")
  content_type = "image/jpg"
}

resource "aws_s3_object" "object3" {
  bucket = aws_s3_bucket.terraformbucket1234b.id
  key    = "coffee.jpg"
  source = "Website/coffee.jpg"
  etag         = filemd5("Website/coffee.jpg")
  content_type = "image/jpg"
}