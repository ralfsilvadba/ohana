terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ----------------------
# VPC
# ----------------------
resource "aws_vpc" "ohana" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
    Env  = var.env
  }
}

# ----------------------
# Subnet pública
# ----------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.ohana.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true    # IP público automático
  availability_zone       = var.az  # opcional; deixe "" p/ deixar a AWS escolher

  tags = {
    Name = "${var.name_prefix}-public-subnet"
    Env  = var.env
  }
}

# ----------------------
# Internet Gateway
# ----------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ohana.id

  tags = {
    Name = "${var.name_prefix}-igw"
    Env  = var.env
  }
}

# ----------------------
# Route Table + rota default p/ Internet
# ----------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ohana.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.name_prefix}-public-rt"
    Env  = var.env
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ----------------------
# Security Group (abrir 22, 80, 443, 3000)
# ----------------------
resource "aws_security_group" "sg_ohana" {
  name        = "${var.name_prefix}-sg"
  description = "Acesso público básico para ohana (SSH/HTTP/HTTPS/Grafana)"
  vpc_id      = aws_vpc.ohana.id

  # SSH somente do seu IP (ou bloco configurado)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Grafana (3000)
  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.grafana_open ? ["0.0.0.0/0"] : [var.allowed_http_cidr]
    ipv6_cidr_blocks = var.grafana_open ? ["::/0"] : []
  }

  # Egress liberado
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.name_prefix}-sg"
    Env  = var.env
  }
}

# ----------------------
# (Opcional) Elastic IP para a sua EC2
# Associe depois na instância ou por módulo de compute.
# ----------------------
resource "aws_eip" "eip_ohana" {
  domain = "vpc"
  tags = {
    Name = "${var.name_prefix}-eip"
    Env  = var.env
  }
}
