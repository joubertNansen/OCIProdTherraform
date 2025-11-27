variable "compartment_id" {}
variable "availability_domain" {}
variable "shape" { default = "VM.Standard2.1" }
variable "display_name" {}
variable "image_id" {}
variable "subnet_id" {}
variable "assign_public_ip" { type = bool, default = false }
variable "ssh_public_key" {}
