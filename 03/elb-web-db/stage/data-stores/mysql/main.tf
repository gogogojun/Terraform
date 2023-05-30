# 목적: MySQL DB 생성

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket         = "bucket-gjh-98585488"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "myTFLocks-table"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_db_instance" "myDBInstance" {
  identifier_prefix = "my-"
  allocated_storage = 10
  db_name           = "myDB"
  engine            = "Mysql"
  instance_class    = "db.t2.micro"

  username            = var.dbuser
  password            = var.dbpassword
  skip_final_snapshot = true
}

