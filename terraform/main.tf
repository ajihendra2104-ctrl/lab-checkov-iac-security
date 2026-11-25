terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

# 1. S3 Bucket dengan akses publik diblokir
resource "aws_s3_bucket" "data" {
  bucket = "my-company-data-bucket"
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 2. Security Group dengan akses terbatas
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Security group with restricted inbound access"

  ingress {
    description = "SSH from authorized IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.10/32"]
  }

  ingress {
    description = "MySQL from private network only"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
}

# 3. IAM Policy dengan prinsip least privilege
resource "aws_iam_policy" "admin" {
  name = "limited-s3-read-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = ["arn:aws:s3:::my-company-data-bucket/*"]
    }]
  })
}

# 4. RDS tidak dapat diakses publik dan menggunakan enkripsi
resource "aws_db_instance" "main" {
  identifier          = "mydb"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  username            = "admin"
  password            = var.db_password
  publicly_accessible = false
  storage_encrypted   = true
  skip_final_snapshot = true
}

variable "db_password" {
  description = "Database password supplied securely at deployment"
  type        = string
  sensitive   = true
}

# 5. EC2 menggunakan enkripsi EBS dan IMDSv2
resource "aws_instance" "web" {
  ami                    = "ami-0123456789abcdef0"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web.id]

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens = "required"
  }
}
