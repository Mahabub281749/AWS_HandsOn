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

data "aws_region" "current" {}
data "aws_partition" "current" {}

resource "aws_iam_instance_profile" "Demoprofile" {
  name = "Demo_profile"
  role = aws_iam_role.DemoRole.name
}

resource "aws_iam_role" "DemoRole" {
  name = "Demo_role"
  path = "/"

    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "DemoPolicy" {
  name = "DemoPolicy"
  role = aws_iam_role.DemoRole.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "imagebuilder:GetComponent"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": "*",
            "Condition": {
                "ForAnyValue:StringEquals": {
                    "kms:EncryptionContextKeys": "aws:imagebuilder:arn",
                    "aws:CalledVia": [
                        "imagebuilder.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::ec2imagebuilder*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:log-group:/aws/imagebuilder/*"
        }
    ]

  })
}

resource "aws_imagebuilder_component" "DemoComponent" {
  data = yamlencode({
    phases = [{
      name = "build"
      steps = [{
        action = "ExecuteBash"
        inputs = {
          commands = ["echo 'hello world'"]
        }
        name      = "ExecuteBash"
        onFailure = "Continue"
      }]
    }]
    schemaVersion = 1.0
  })
  name     = "DemoComponent"
  platform = "Linux"
  version  = "1.0.0"
}

resource "aws_imagebuilder_image_recipe" "DemoRecipe" {
  block_device_mapping {
    device_name = "/dev/xvdb"

    ebs {
      delete_on_termination = true
      volume_size           = 5
      volume_type           = "gp2"
    }
  }

  component {
    component_arn = aws_imagebuilder_component.DemoComponent.arn
  }

  name         = "DemoRecipe"
  parent_image = "arn:${data.aws_partition.current.partition}:imagebuilder:${data.aws_region.current.name}:aws:image/amazon-linux-2-x86/x.x.x"
  version      = "1.0.0"
}

resource "aws_imagebuilder_infrastructure_configuration" "DemoInfra" {
  description                   = "Demo Infrastracture"
  instance_profile_name         = aws_iam_instance_profile.Demoprofile.name
  instance_types                = ["t2.nano"]
  name                          = "DemoInfra"
  terminate_instance_on_failure = true


}

resource "aws_imagebuilder_distribution_configuration" "DemoDistri" {
  name = "DemoDistribution"

  distribution {
    ami_distribution_configuration {
      ami_tags = {
        CostCenter = "IT"
      }
    }
    region = data.aws_region.current.name
  }
}
resource "aws_imagebuilder_image_pipeline" "example" {
  image_recipe_arn                 = aws_imagebuilder_image_recipe.DemoRecipe.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.DemoInfra.arn
  name                             = "DemoPipline"

  schedule {
    schedule_expression = "manual"
  }
}

resource "aws_imagebuilder_image" "example" {
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.DemoDistri.arn
  image_recipe_arn                 = aws_imagebuilder_image_recipe.DemoRecipe.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.DemoInfra.arn
}



