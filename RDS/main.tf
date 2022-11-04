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

resource "aws_db_instance" "RDS" {
  allocated_storage       = 10
  max_allocated_storage   = 100
  db_name                 = "mydb_RDS"
  engine                  = "mysql"
  engine_version          = "8.0.28"
  instance_class          = "db.t2.micro"
  username                = "Parvez"
  password                = "Rifles105109!"
  parameter_group_name    = "default.mysql8.0"
  skip_final_snapshot     = true
  maintenance_window      = "Fri:09:00-Fri:09:30"
  backup_retention_period = 0
}


resource "aws_db_snapshot" "RDS_Snapshot" {
  db_instance_identifier = aws_db_instance.RDS.id
  db_snapshot_identifier = "rdsnapshot"
}

resource "aws_db_snapshot_copy" "RDS_Snapshot_Copy" {
  source_db_snapshot_identifier = aws_db_snapshot.RDS_Snapshot.db_snapshot_arn
  target_db_snapshot_identifier = "rdssnapshotcopy"
}

resource "aws_vpc" "demovpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "RDS_VPC"
  }
}


resource "aws_subnet" "demosubnet" {
  vpc_id            = aws_vpc.demovpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "Demo subnet"
  }
}

resource "aws_subnet" "demosubnet1" {
  vpc_id            = aws_vpc.demovpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1b"
  tags = {
    Name = "Demo subnet 1"
  }
}

resource "aws_db_subnet_group" "RDS_Subnet" {
  name       = "rds_subnet"
  subnet_ids = [aws_subnet.demosubnet.id, aws_subnet.demosubnet1.id]

  tags = {
    Name = "My DB subnet group"
  }
}