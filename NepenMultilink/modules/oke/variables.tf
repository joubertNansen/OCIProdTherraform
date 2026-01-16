variable "compartment_id" {
  description = "OCID do compartimento"
  type        = string
}

variable "vcn_id" {
  description = "OCID da VCN"
  type        = string
}

variable "subnet_id" {
  description = "OCID da subnet"
  type        = string
}

variable "availability_domain" {
  description = "Availability Domain"
  type        = string
}

variable "node_image_id" {
  description = "OCID da imagem para nodes"
  type        = string
}