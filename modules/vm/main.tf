resource "oci_core_instance" "this" {
  compartment_id       = var.compartment_id
  availability_domain  = var.availability_domain
  shape                = var.shape
  display_name         = var.display_name

  source_details {
    source_type = "image"
    image_id    = var.image_id
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = var.assign_public_ip
    display_name     = "${var.display_name}-vnic"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  lifecycle {
    create_before_destroy = true
  }
}
