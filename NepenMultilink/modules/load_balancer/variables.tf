variable "compartment_id" {
  description = "OCID do compartimento"
  type        = string
}

variable "subnet_ids" {
  description = "Lista de OCIDs das subnets"
  type        = list(string)
}

variable "backend_set_instances" {
  description = "Lista de instâncias para backend set"
  type = list(object({
    instance_id = string
    ip_address  = string
  }))
  default = []
}