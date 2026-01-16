variable "compartment_id" {
  description = "OCID do compartimento"
  type        = string
}

variable "vcn_cidr" {
  description = "CIDR da VCN"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR da subnet pública"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR da subnet privada"
  type        = string
}