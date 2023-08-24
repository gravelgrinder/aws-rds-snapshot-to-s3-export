terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

###resource "aws_iam_role" "iam_for_lambda" {
###  name               = "iam_for_lambda"
###  assume_role_policy = <<EOF
###{
###  "Version": "2012-10-17",
###  "Statement": [
###    {
###      "Action": "sts:AssumeRole",
###      "Principal": {
###        "Service": "lambda.amazonaws.com"
###      },
###      "Effect": "Allow",
###      "Sid": ""
###    }
###  ]
###}
###EOF
###}

################################################################################
### Create Security Group for RDS instances
################################################################################
resource "aws_security_group" "rds_sg" {
  name        = "djl-tf-rds-sg"
  description = "Security group for the RDS instance."
  vpc_id      = "vpc-00b09e53c6e62a994"

  ingress {
    description      = "Allow Workspaces to access SQL Server"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "djl-tf-rds-sg"
  }
}
################################################################################


################################################################################
### Create MySQL RDS instance
################################################################################
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "tf_db_group"
  subnet_ids = ["subnet-045bd90a8091ea930", "subnet-0871b35cbe9d0c1cf", "subnet-069a69e50bd1ebb23"]
}

resource "aws_db_instance" "mysqlrds" {
  allocated_storage    = 10
  storage_encrypted    = true
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  publicly_accessible  = false
  identifier           = "djldb01"
  name                 = "djl"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name  = aws_db_subnet_group.db_subnet_group.id
  multi_az = true
  backup_retention_period = 35
  skip_final_snapshot  = true
  tags = {Name = "djldb01", phidb = true, s3export = true, storagetier = "s3glacier"}
  copy_tags_to_snapshot = true
}



#resource "aws_db_instance" "sqlserver" {
#  identifier            = "sqlserver-1"
#  allocated_storage     = 20
#  max_allocated_storage = 100
#  backup_retention_period = 0
#  engine                = "sqlserver-ex"
#  engine_version        = "15.00.4073.23.v1"
#  license_model         = "license-included"
#  instance_class        = "db.t3.small"
#  #name                  = "sqlserver-1"
#  username              = "admin"
#  password              = "admin123"
#  vpc_security_group_ids = [aws_security_group.rds_sg.id]
#  db_subnet_group_name  = aws_db_subnet_group.db_subnet_group.id
#  skip_final_snapshot   = true
#  tags = {Name = "sqlserver-1"}
#}
################################################################################