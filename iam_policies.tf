
/*
Recurso: Política IAM por projeto
 - Cria políticas de identidade (IAM) usando `for_each` sobre var.project_policies.
 - Cada entrada deve conter o compartment_id onde a policy será criada e a
   lista de statements (strings) que definem as permissões.
 - Exemplo de statement: "Allow group Devs to manage all-resources in compartment ..."
*/
resource "oci_identity_policy" "project_policy" {
  for_each = var.project_policies

  name           = "policy-${each.key}"
  description    = "Política IAM para o projeto ${each.key}"
  compartment_id = each.value.compartment_id
  statements     = each.value.statements
}
