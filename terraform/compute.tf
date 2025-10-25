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

    # Instala Docker e Compose plugin
    dnf -y install docker docker-compose-plugin

    # Habilita e inicia Docker
    systemctl enable --now docker

    # Permite 'ec2-user' usar docker sem sudo
    usermod -aG docker ec2-user

    # Pasta do projeto
    mkdir -p /opt/ohana/provisioning/datasources
    mkdir -p /opt/ohana/mimir
    mkdir -p /opt/ohana/{minio-data,oracle-data,alloy-data,mimir-data}
    chown -R ec2-user:ec2-user /opt/ohana

    # Dica: copie/edite seu docker-compose.yml depois em /opt/ohana
    # Ex.: scp -i sua-chave.pem docker-compose.yml ec2-user@$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):/opt/ohana/

    # (Opcional) Abrir porta do firewalld local – SG já controla, então mantemos padrão
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
