variable "compartment_id" {}
variable "vcn_cidr" { default = "10.0.0.0/16" }
variable "display_name" { default = "shared-vcn" }

resource "oci_core_virtual_network" "vcn" {
  compartment_id = var.compartment_id
  display_name   = var.display_name
  cidr_block     = var.vcn_cidr
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.display_name}-igw"
}
