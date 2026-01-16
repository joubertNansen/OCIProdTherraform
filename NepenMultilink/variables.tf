# ====================================================================
# ARQUIVO: variables.tf
# DESCRIÇÃO: Variáveis para infraestrutura NepenMultilink
# ====================================================================

# ---- AUTENTICAÇÃO OCI ----
variable "tenancy_ocid" {
  description = "OCID do tenancy OCI"
  type        = string
}

variable "user_ocid" {
  description = "OCID do usuário OCI"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint da chave API"
  type        = string
}

variable "private_key_path" {
  description = "Caminho para chave privada"
  type        = string
}

variable "region" {
  description = "Região OCI"
  type        = string
  default     = "sa-saopaulo-1"
}

# ---- COMPARTIMENTO ----
variable "compartment_id" {
  description = "OCID do compartimento"
  type        = string
}

# ---- REDE ----
variable "vcn_cidr" {
  description = "CIDR da VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR da subnet pública"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR da subnet privada"
  type        = string
  default     = "10.0.2.0/24"
}

# ---- AVAILABILITY DOMAIN ----
variable "availability_domain" {
  description = "Availability Domain"
  type        = string
}

# ---- DATABASE CONFIGURAÇÕES ----
variable "db_admin_password" {
  description = "Senha admin do banco"
  type        = string
  sensitive   = true
}

variable "mongodb_admin_password" {
  description = "Senha admin MongoDB"
  type        = string
  sensitive   = true
}

# ---- INSTÂNCIAS COMPUTE ----
variable "db_instance_shape" {
  description = "Shape para instância de banco de dados"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "db_instance_ocpus" {
  description = "OCPUs para instância DB"
  type        = number
  default     = 8
}

variable "db_instance_memory" {
  description = "Memória para instância DB (GB)"
  type        = number
  default     = 120
}

variable "app_instance_shape" {
  description = "Shape para instâncias de aplicação"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "app_instance_ocpus" {
  description = "OCPUs para instâncias app"
  type        = number
  default     = 4
}

variable "app_instance_memory" {
  description = "Memória para instâncias app (GB)"
  type        = number
  default     = 60
}

# ---- IMAGENS ----
variable "ubuntu_image_id" {
  description = "OCID da imagem Ubuntu"
  type        = string
}

# ---- DATABASE INSTANCES ----
variable "db_shape" {
  description = "Shape para instância PostgreSQL"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "db_ocpus" {
  description = "OCPUs para instância PostgreSQL"
  type        = number
  default     = 8
}

variable "db_memory" {
  description = "Memória para instância PostgreSQL (GB)"
  type        = number
  default     = 120
}

variable "mongodb_shape" {
  description = "Shape para instância MongoDB"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "mongodb_ocpus" {
  description = "OCPUs para instância MongoDB"
  type        = number
  default     = 4
}

variable "mongodb_memory" {
  description = "Memória para instância MongoDB (GB)"
  type        = number
  default     = 60
}

# ---- SSH ----
variable "ssh_public_key" {
  description = "Chave SSH pública"
  type        = string
}