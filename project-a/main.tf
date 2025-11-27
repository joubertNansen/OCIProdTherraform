variable "compartment_id" {}
variable "ssh_public_key" {}

module "network" {
  source         = "../modules/network"
  compartment_id = var.compartment_id
  vcn_cidr       = "10.1.0.0/16"
  display_name   = "project-a-shared-vcn-prod"
}

module "vm" {
  source             = "../modules/vm"
  compartment_id     = var.compartment_id
  availability_domain = "${var.compartment_id}-AD-1" # replace with real AD
  display_name       = "project-a-instance-prod"
  image_id           = "" # set image OCID
  subnet_id          = module.network.vcn_id # replace with subnet when available
  assign_public_ip   = false
  ssh_public_key     = var.ssh_public_key
}
