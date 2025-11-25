# ====================================================================
# ARQUIVO: iam_policies.tf
# DESCRIÇÃO: Define políticas de controle de acesso (IAM - Identity and Access Management)
#            Determina quem pode fazer o quê dentro de cada compartimento
# ====================================================================
# Recurso: Política de Identidade e Acesso
# Esta política controla as permissões dos usuários e grupos na Oracle Cloud
/*
Recurso: Política IAM por projeto
 - Cria políticas de identidade (IAM) usando `for_each` sobre var.project_policies.
 - Cada entrada deve conter o compartment_id onde a policy será criada e a
   lista de statements (strings) que definem as permissões.
 - Exemplo de statement: "Allow group Devs to manage all-resources in compartment ..."
*/
resource "oci_identity_policy" "project_policy" {
  # for_each: Cria uma política para cada projeto definido em var.project_policies
  for_each = var.project_policies
  name = "policy-${each.key}" # name: Nome da política (ex: policy-projeto-a-nonprod)
  description = "Política IAM para o projeto ${each.key}" # description: Descrição em linguagem natural do que essa política faz
  compartment_id = each.value.compartment_id # compartment_id: ID do compartimento onde essa política se aplica
  statements = each.value.statements # statements: Lista de regras de permissão # Exemplo: "Allow group Devs to manage all-resources in compartment projeto-a"
}
