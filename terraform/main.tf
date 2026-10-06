provider "aws" {
  region = var.aws_region
}

# 1. Security Group allowing SSH (22) and Redis (6379)
resource "aws_security_group" "redis_sg" {
  name        = "redis-multi-os-sg"
  description = "Allow SSH and Redis inbound"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
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

# 2. Ubuntu 22.04 AMI Fetching
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# 3. Amazon Linux 2023 AMI Fetching
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 4. Instance 1: Ubuntu Server
resource "aws_instance" "ubuntu_redis" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.redis_sg.id]

  tags = {
    Name = "Redis-Ubuntu-Server"
    Role = "redis-server"
    OS   = "ubuntu"
  }
}

# 5. Instance 2: Amazon Linux Server
resource "aws_instance" "al2023_redis" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.redis_sg.id]

  tags = {
    Name = "Redis-AL2023-Server"
    Role = "redis-server"
    OS   = "amazon-linux"
  }
}