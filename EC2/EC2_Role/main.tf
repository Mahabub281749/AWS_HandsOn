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

resource "aws_default_vpc" "main" {
  tags = {
    name = "main"
  }
}

resource "aws_security_group" "HelloWorld_security" {
    name = "Helloworld_security"
    description = "Allow TLS inbound traffic"
    vpc_id = aws_default_vpc.main.id

    ingress = [ {
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
      from_port = 80
      ipv6_cidr_blocks = []
      prefix_list_ids = [ ]
      protocol = "tcp"
      security_groups = [ ]
      self = false
      to_port = 80
    }, 
    {
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH"
      from_port = 22
      ipv6_cidr_blocks = []
      prefix_list_ids = [ ]
      protocol = "tcp"
      security_groups = [ ]
      self = false
      to_port = 22
    }]

    egress = [ {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Outgoing traffic"
      from_port = 0
      ipv6_cidr_blocks = [ ]
      prefix_list_ids = [ ]
      protocol = "-1"
      security_groups = [ ]
      self = false
      to_port = 0
    } ]
    
  
}

resource "aws_iam_role" "HelloWorldRole" {
  name = "HelloWorldRole"

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
      },
    ]
  })
}
resource "aws_iam_role_policy" "HelloWorldRolePolicy" {
  name = "HelloWorldRolePolicy"
  role = aws_iam_role.HelloWorldRole.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:GenerateCredentialReport",
                "iam:GenerateServiceLastAccessedDetails",
                "iam:Get*",
                "iam:List*",
                "iam:SimulateCustomPolicy",
                "iam:SimulatePrincipalPolicy"
            ],
            "Resource": "*"
        }
    ]

  })
}

resource "aws_iam_instance_profile" "HelloWorldProfile" {
  name = "HelloWorldProfile"
  role = aws_iam_role.HelloWorldRole.name
}

resource "aws_instance" "Demo" {
  ami           = var.ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.HelloWorld_security.name]
  iam_instance_profile = aws_iam_instance_profile.HelloWorldProfile.name
  tags = {
    Name = "HelloWorld"
  }
  
}

output "public_ip" {
  value = aws_instance.Demo.public_ip
}