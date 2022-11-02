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

provider "aws" {
  alias      = "east"
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}

resource "aws_s3_bucket" "s3_bucket_origin_1234" {
  bucket   = "s3-bucket-origin-1234"
  provider = aws.east

  tags = {
    Name        = "My bucket Origin"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "s3_bucket_replica_1234" {
  bucket = "s3-bucket-replica-1234"

  tags = {
    Name        = "My bucket Replica"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "public_reads_origin" {
  provider = aws.east
  bucket   = aws_s3_bucket.s3_bucket_origin_1234.id
  acl      = "private"
}

resource "aws_s3_bucket_acl" "public_reads_destination" {
  bucket = aws_s3_bucket.s3_bucket_replica_1234.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning_example_origin" {
  provider = aws.east
  bucket   = aws_s3_bucket.s3_bucket_origin_1234.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example_destination" {
  bucket = aws_s3_bucket.s3_bucket_replica_1234.id
  versioning_configuration {
    status = "Enabled"
  }
}



resource "aws_iam_role" "replication" {
  name = "tf-iam-role-replication-12345"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
  name = "tf-iam-role-policy-replication-12345"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:ListBucket",
                "s3:GetReplicationConfiguration",
                "s3:GetObjectVersionForReplication",
                "s3:GetObjectVersionAcl",
                "s3:GetObjectVersionTagging",
                "s3:GetObjectRetention",
                "s3:GetObjectLegalHold"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::s3-bucket-origin-1234",
                "arn:aws:s3:::s3-bucket-origin-1234/*",
                "arn:aws:s3:::s3-bucket-replica-1234",
                "arn:aws:s3:::s3-bucket-replica-1234/*"
            ]
        },
        {
            "Action": [
                "s3:ReplicateObject",
                "s3:ReplicateDelete",
                "s3:ReplicateTags",
                "s3:ObjectOwnerOverrideToBucketOwner"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::s3-bucket-origin-1234/*",
                "arn:aws:s3:::s3-bucket-replica-1234/*"
            ]
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  provider = aws.east
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.versioning_example_origin]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.s3_bucket_origin_1234.id
  

  rule {
    id = "foobar"

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.s3_bucket_replica_1234.arn
      storage_class = "STANDARD"
    }
    
  }
}

resource "aws_s3_object" "object2" {
  provider     = aws.east
  bucket       = aws_s3_bucket.s3_bucket_origin_1234.id
  key          = "beach.jpg"
  source       = "beach.jpg"
  etag         = filemd5("beach.jpg")
  content_type = "image/jpg"
}

resource "aws_s3_object" "object3" {
  provider     = aws.east
  bucket       = aws_s3_bucket.s3_bucket_origin_1234.id
  key          = "coffee.jpg"
  source       = "coffee.jpg"
  etag         = filemd5("coffee.jpg")
  content_type = "image/jpg"
}