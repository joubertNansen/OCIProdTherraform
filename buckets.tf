
/*
Recurso: Bucket de Object Storage (um por projeto)
 - Usa `for_each` para criar um bucket para cada entrada em `var.project_buckets`.
 - `each.key` é o nome lógico do projeto; `each.value` contém os atributos
   (compartment_id e namespace) necessários para criar o bucket.
 - Ajuste `storage_tier` conforme necessidade (Standard, Archive, etc.).
*/
resource "oci_objectstorage_bucket" "project_bucket" {
  for_each = var.project_buckets

  name           = "bucket-${each.key}"
  compartment_id = each.value.compartment_id
  namespace      = each.value.namespace
  storage_tier   = "Standard"
}
