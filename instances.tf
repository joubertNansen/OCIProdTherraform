
resource "oci_core_instance" "project_instance" {
  for_each = var.project_instances

  availability_domain = each.value.availability_domain
  compartment_id      = each.value.compartment_id
  shape               = each.value.shape

  create_vnic_details {
    subnet_id = each.value.subnet_id
  }

  source_details {
    source_type = "image"
    image_id    = each.value.image_id
  }
  display_name = "instance-${each.key}"
}
