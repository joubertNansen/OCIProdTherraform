variable "compartment_id" {}
variable "availability_domain" {}

module "vm" {
  source = "../.."
  compartment_id = var.compartment_id
  availability_domain = var.availability_domain
  display_name = "example-vm"
  image_id = "ocid1.image.oc1..example"
  subnet_id = "ocid1.subnet.oc1..example"
  ssh_public_key = file("~/.ssh/id_rsa.pub")
}
