variable "compartment_id" {
  description = "OCID do compartimento"
  type        = string
}

variable "public_subnet_id" {
  description = "OCID da subnet pública"
  type        = string
}

variable "private_subnet_id" {
  description = "OCID da subnet privada"
  type        = string
}

variable "availability_domain" {
  description = "Availability Domain"
  type        = string
}

variable "app_instance_shape" {
  description = "Shape para instâncias de aplicação"
  type        = string
}

variable "app_instance_ocpus" {
  description = "OCPUs para instâncias app"
  type        = number
}

variable "app_instance_memory" {
  description = "Memória para instâncias app (GB)"
  type        = number
}

variable "ubuntu_image_id" {
  description = "OCID da imagem Ubuntu"
  type        = string
}

variable "ssh_public_key" {
  description = "Chave SSH pública"
  type        = string
}