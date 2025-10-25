variable "aws_region" {
  description = "Região AWS (ex.: sa-east-1, us-east-1, us-east-2)"
  type        = string
  default     = "sa-east-1"
}

variable "env" {
  description = "Ambiente (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "name_prefix" {
  description = "Prefixo padrão para nomes"
  type        = string
  default     = "ohana"
}

variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.80.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR da Subnet pública"
  type        = string
  default     = "10.80.10.0/24"
}

variable "az" {
  description = "Availability Zone (ex.: sa-east-1a). Deixe vazio para deixar a AWS escolher."
  type        = string
  default     = ""
}

variable "ssh_cidr" {
  description = "Bloco CIDR permitido para SSH (ex.: seu IP /32)"
  type        = string
  default     = "0.0.0.0/0" # troque por segurança, ex.: 200.200.200.200/32
}

variable "grafana_open" {
  description = "Se true, libera Grafana:3000 para Internet; se false, restringe ao allowed_http_cidr"
  type        = bool
  default     = true
}

variable "allowed_http_cidr" {
  description = "CIDR permitido para portas HTTP customizadas quando grafana_open=false"
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3.small" # pode usar t3.micro para começar
}

variable "key_name" {
  description = "Nome do Key Pair existente na região"
  type        = string
}

variable "root_volume_gb" {
  description = "Tamanho do volume raiz (GB)"
  type        = number
  default     = 30
}
