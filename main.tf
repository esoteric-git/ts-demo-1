terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # AWS credentials will be automatically picked up from environment variables
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "ts-demo-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ts-demo-igw"
  }
}

# Public Subnet (for vm-1)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "ts-demo-public"
  }
}

# Private Subnet (for vm-2)
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "ts-demo-private"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "ts-demo-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Groups
resource "aws_security_group" "vm1" {
  name        = "ts-demo-vm1"
  description = "Security group for vm-1 (Tailscale subnet router)"
  vpc_id      = aws_vpc.main.id

  # Allow all outbound (needed for Tailscale)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound SSH (optional, for troubleshooting)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vm2" {
  name        = "ts-demo-vm2"
  description = "Security group for vm-2 (private instance)"
  vpc_id      = aws_vpc.main.id

  # Allow all traffic from vm1
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.vm1.id]
  }

  # Allow outbound traffic (needed for package installation)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instances
resource "aws_instance" "vm1" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id

  vpc_security_group_ids = [aws_security_group.vm1.id]

  user_data = <<-EOF
              #!/bin/bash
              # Enable IP forwarding for Amazon Linux
              echo 'net.ipv4.ip_forward = 1' | sudo tee /etc/sysctl.d/99-tailscale.conf
              sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

              # Install and configure Tailscale
              curl -fsSL https://tailscale.com/install.sh | sh
              tailscale up --authkey=${var.tailscale_auth_key} --hostname="ts-demo-vm1" --advertise-routes=10.0.2.0/24 --ssh --accept-routes
              EOF

  tags = {
    Name = "ts-demo-vm1"
  }
}

resource "aws_instance" "vm2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private.id

  vpc_security_group_ids = [aws_security_group.vm2.id]

  tags = {
    Name = "ts-demo-vm2"
  }
} 