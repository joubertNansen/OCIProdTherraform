module "vcn" {
  source         = "./vcn"
  compartment_id = var.compartment_id
  vcn_cidr       = var.vcn_cidr
  display_name   = var.display_name
}

module "igw" {
  source         = "./igw"
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = var.display_name
}

output "vcn_id" { value = module.vcn.vcn_id }
output "igw_id" { value = module.igw.igw_id }
