
resource "oci_identity_policy" "project_policy" {
  for_each = var.project_policies

  name           = "policy-${each.key}"
  description    = "Política IAM para o projeto ${each.key}"
  compartment_id = each.value.compartment_id
  statements     = each.value.statements
}
