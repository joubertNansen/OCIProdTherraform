variable "compartment_id" {
  description = "OCID do compartimento"
  type        = string
}

variable "subnet_id" {
  description = "OCID da subnet privada"
  type        = string
}

variable "availability_domain" {
  description = "Availability Domain"
  type        = string
}

variable "db_admin_password" {
  description = "Senha admin PostgreSQL"
  type        = string
  sensitive   = true
}

variable "mongodb_admin_password" {
  description = "Senha admin MongoDB"
  type        = string
  sensitive   = true
}

# Novas variáveis para instâncias Compute
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

variable "ubuntu_image_id" {
  description = "OCID da imagem Ubuntu"
  type        = string
}

variable "ssh_public_key" {
  description = "Chave SSH pública"
  type        = string
}