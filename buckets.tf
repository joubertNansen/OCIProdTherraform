
resource "oci_objectstorage_bucket" "project_bucket" {
  for_each = var.project_buckets

  name           = "bucket-${each.key}"
  compartment_id = each.value.compartment_id
  namespace      = each.value.namespace
  storage_tier   = "Standard"
}
