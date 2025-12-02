# ====================================================================
# ARQUIVO: iam_policies.tf
# DESCRIÇÃO: Define políticas de controle de acesso (IAM - Identity and Access Management)
#            Determina quem pode fazer o quê dentro de cada compartimento
# ====================================================================

# Recurso: Política de Identidade e Acesso
# Esta política controla as permissões dos usuários e grupos na Oracle Cloud
# Política IAM por projeto
# - Cria políticas de identidade (IAM) usando for_each sobre var.project_policies.
# - Cada entrada deve conter o compartment_id onde a policy será criada e a
#   lista de statements (strings) que definem as permissões.
# - Exemplo de statement: "Allow group Devs to manage all-resources in compartment ..."
resource "oci_identity_policy" "project_policy" {
  # for_each: Cria uma política para cada projeto definido em var.project_policies
  for_each       = var.project_policies
  name           = "policy-${each.key}"                      # name: Nome da política (ex: policy-projeto-a-nonprod)
  description    = "Política IAM para o projeto ${each.key}" # description: Descrição em linguagem natural do que essa política faz
  # Create project policies in the nonprod root compartment by default.
  # This ensures the policy compartment subtree contains the referenced project compartments
  # (policy statements reference compartments by name and must be within the policy subtree).
  compartment_id = lookup(each.value, "compartment_id", "") != "" ? lookup(each.value, "compartment_id", "") : (
    lookup(each.value, "policy_compartment", "") != "" ? lookup(each.value, "policy_compartment", "") : local.selected_root_compartment_id
  )

  # Transform provided statements to reference the actual OCI compartment display name
  # If user supplied `compartment = "projeto-x-nonprod"` in the policy map, the code
  # replaces occurrences of that logical name with the compartment name used in OCI
  # (uppercased, dashes replaced with underscores) so the API can match the compartment
  # when validating the policy statements.
  statements = [
    for s in lookup(each.value, "statements", []) :
    lookup(each.value, "compartment", "") != "" ? replace(s, lookup(each.value, "compartment", ""), upper(replace(lookup(each.value, "compartment", ""), "-", "_"))) : s
  ]
}
