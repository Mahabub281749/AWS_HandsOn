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

resource "aws_vpc" "demovpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "AGS_VPC"
  }
}

resource "aws_internet_gateway" "demogateway" {
  vpc_id = aws_vpc.demovpc.id

}

# Creating 1st subnet 
resource "aws_subnet" "demosubnet" {
  vpc_id                  = aws_vpc.demovpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "Demo subnet"
  }
}
# Creating 2nd subnet 
resource "aws_subnet" "demosubnet1" {
  vpc_id                  = aws_vpc.demovpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "Demo subnet 1"
  }
}

#Creating Route Table
resource "aws_route_table" "route" {
  vpc_id = aws_vpc.demovpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demogateway.id
  }
  tags = {
    Name = "Route to internet"
  }
}
resource "aws_route_table_association" "rt1" {
  subnet_id      = aws_subnet.demosubnet.id
  route_table_id = aws_route_table.route.id
}
resource "aws_route_table_association" "rt2" {
  subnet_id      = aws_subnet.demosubnet1.id
  route_table_id = aws_route_table.route.id
}

# Creating Security Group for ELB
resource "aws_security_group" "demosg1" {
  name        = "Demo Security Group"
  description = "Demo Module"
  vpc_id      = aws_vpc.demovpc.id
  # Inbound Rules
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Outbound Rules
  # Internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "web_elb" {
  name = "web-elb"
  security_groups = [
    "${aws_security_group.demosg1.id}"
  ]
  subnets = [
    "${aws_subnet.demosubnet.id}",
    "${aws_subnet.demosubnet1.id}"
  ]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "80"
    instance_protocol = "http"
  }
}

resource "aws_security_group" "EC2_security" {
  name        = "EC2_security"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.demovpc.id

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


resource "aws_launch_template" "ASG_template" {
  name_prefix   = "ASG-Terraform"
  image_id      = var.ami
  instance_type = var.instance_type
}

resource "aws_autoscaling_group" "ASG" {
  vpc_zone_identifier = ["${aws_subnet.demosubnet.id}","${aws_subnet.demosubnet1.id}"]
  desired_capacity  = 2
  max_size          = 4
  min_size          = 1
  health_check_type = "ELB"
  load_balancers = [
    "${aws_elb.web_elb.id}"
  ]

  launch_template {
    id      = aws_launch_template.ASG_template.id
    version = "$Latest"
  }
}