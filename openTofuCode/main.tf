provider "aws" {
  region = var.region
}

# Get the current account ID
data "aws_caller_identity" "current" {}

# Create a private S3 bucket
resource "aws_s3_bucket" "example_bucket" {
  bucket = var.bucket_name
}

# Upload setup script in S3 bucket
resource "aws_s3_object" "setup_script" {
  bucket = aws_s3_bucket.example_bucket.bucket
  key    = "user-data.sh"
  source = var.user_data  #local path to user-data.sh initial config file
  acl    = "private"
}

# Create policy to allow access to S3 bucket
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.example_bucket.arn}/*"]
  }
}

# Create IAM role for EC2 instance
resource "aws_iam_role" "ncr_ec2_role" {
  name = "ncr_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach S3 policy to IAM role
resource "aws_iam_role_policy" "s3_access_policy" {
  name   = "s3_access_policy"
  role   = aws_iam_role.ncr_ec2_role.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

# Create an IAM instance profile
resource "aws_iam_instance_profile" "ncr_instance_profile" {
  name = "ncr_instance_profile"
  role = aws_iam_role.ncr_ec2_role.name
}

# Create an S3 bucket policy to allow access only to the specific IAM role
resource "aws_s3_bucket_policy" "example_bucket_policy" {
  bucket = aws_s3_bucket.example_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ncr_ec2_role"
        },
        Action = "s3:GetObject",
        Resource = "arn:aws:s3:::${aws_s3_bucket.example_bucket.bucket}/setup.sh"
      }
    ]
  })
}

# Create a security group to allow HTTP access on port 8080, outbound traffic on ports 80 and 443, and SSH access on port 22
resource "aws_security_group" "ncr_sg" {
  name        = "ncr_sg"
  description = "Allow HTTP traffic on port 8080, SSH access on port 22"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # debug: this is only necessary for pipe-tf-ncr project. If no more necessary then port 52760 can be removed
    from_port   = 52760
    to_port     = 52760
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define the key pair. It can be null or the key pair created for ssh access based on var.create_key_pair value
resource "aws_key_pair" "deployer" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = "deployer"
  public_key = file(var.public_key_path)
}


# Create an EC2 instance to run the NCR service
resource "aws_instance" "ncr_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.ncr_sg.name]
  key_name      = var.create_key_pair ? aws_key_pair.deployer[0].key_name : null
  iam_instance_profile  = aws_iam_instance_profile.ncr_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y awscli
              aws s3 cp s3://${aws_s3_bucket.example_bucket.bucket}/user-data.sh ./user-data.sh
              chmod +x ./user-data.sh
              ./user-data.sh
              EOF

  tags = {
    Name = "NCR Instance"
  }
}


