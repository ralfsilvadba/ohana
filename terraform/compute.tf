# =========================
# AMI Amazon Linux 2023 (x86_64)
# =========================
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# =========================
# IAM Role (opcional, p/ SSM)
# =========================
resource "aws_iam_role" "ec2_role" {
  name               = "${var.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# =========================
# EC2
# =========================
resource "aws_instance" "ohana_ec2" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.sg_ohana.id]
  key_name               = var.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Disco raiz
  root_block_device {
    volume_size = var.root_volume_gb
    volume_type = "gp3"
    encrypted   = true
  }

  # User data: instala Docker + Compose e prepara /opt/ohana
  user_data = <<-EOF
    #!/bin/bash
    set -eux

  # Atualiza pacotes
    dnf -y update || true

  # Instala Docker Engine
    dnf -y install docker
    systemctl enable --now docker
    usermod -aG docker ec2-user

  # Instala Compose v2
    dnf -y install docker-compose-plugin || true
    if ! command -v docker-compose &> /dev/null; then
      curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose
    fi

    # Pasta do projeto
    mkdir -p /opt/ohana/{provisioning,datasources,mimir,oracle-data,minio-data,alloy-data,mimir-data}
    chown -R ec2-user:ec2-user /opt/ohana
  EOF

  tags = {
    Name = "${var.name_prefix}-ec2"
    Env  = var.env
  }
}

# =========================
# Associa o Elastic IP já criado ao aplicar a infra de rede
# (usa o aws_eip.eip_ohana existente)
# =========================
resource "aws_eip_association" "ohana_assoc" {
  instance_id   = aws_instance.ohana_ec2.id
  allocation_id = aws_eip.eip_ohana.id
}
