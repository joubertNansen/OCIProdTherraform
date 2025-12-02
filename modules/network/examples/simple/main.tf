variable "compartment_id" {}

module "network" {
  source = "../.."
  compartment_id = var.compartment_id
  vcn_cidr = "10.2.0.0/16"
  display_name = "example-vcn"
}
