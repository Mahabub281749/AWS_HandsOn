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

resource "aws_instance" "Demo" {
  ami           = var.ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.HelloWorld_security.name]

  tags = {
    Name = "HelloWorld"
  }
  user_data = <<EOF
		#!/bin/bash
        # Use this for the user data
        # install httpd
        yum update -y
        yum install -y httpd
        systemctl start httpd
        systemctl enable httpd
        echo "<h1>Hello World form $(hostname -f) </h1>" > /var/www/html/index.html
	EOF
}

resource "aws_security_group" "HelloWorld_security" {
    name = "Helloworld_security"
    description = "Allow TLS inbound traffic"
    vpc_id = aws_default_vpc.main.id

    ingress = [ {
      cidr_blocks = ["0.0.0.0/0"]
      description = "inbound traffic"
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
      description = "inbound traffic"
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

resource "aws_default_vpc" "main" {
  tags = {
    Name = "main"
  }
}

resource "aws_ebs_volume" "HelloWorld_EBS" {
    availability_zone = "us-east-1a"
    size = 8
    tags = {
      "name" = "HelloWorld_EBS"
    }
  
}

output "public_ip" {
  value = aws_instance.Demo.public_ip
}