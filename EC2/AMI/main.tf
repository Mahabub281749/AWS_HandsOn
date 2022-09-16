terraform {
  required_version = ">=1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.29.0"
    }
  }
}

locals {
  server_name = "HelloWorld"
  vpc_name    = "HelloWorld_VPC"
  AMI_name = "HelloWorld_AMI"
  AMI_Server_Name = "HelloWorld_From_AMI"
}

provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""


}

data "aws_region" "current" {}

resource "aws_default_vpc" "HelloWorld_VPC" {
  tags = {
    name   = local.vpc_name
    region = data.aws_region.current.name
  }
}

resource "aws_security_group" "HelloWorld_security" {
  name        = "Helloworld_security"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_default_vpc.HelloWorld_VPC.id

  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "inbound traffic"
    from_port        = 80
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 80
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "inbound traffic"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Outgoing traffic"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]


}

resource "aws_instance" "Demo" {
  ami             = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.HelloWorld_security.name]

  tags = {
    Name = local.server_name
  }
}

resource "aws_ami_from_instance" "HelloWorld_AMI" {
  name               = local.AMI_name
  source_instance_id = aws_instance.Demo.id
}

resource "aws_instance" "Demo_AMI" {
  ami             = aws_ami_from_instance.HelloWorld_AMI.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.HelloWorld_security.name]

  tags = {
    Name = local.AMI_Server_Name
  }
}