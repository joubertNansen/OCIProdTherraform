variable "compartment_id" {}
variable "vcn_id" {}
variable "display_name" { default = "shared-vcn" }

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.display_name}-igw"
}

output "igw_id" { value = oci_core_internet_gateway.igw.id }
