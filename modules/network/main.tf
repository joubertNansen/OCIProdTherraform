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
