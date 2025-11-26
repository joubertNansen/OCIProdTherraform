# ====================================================================
# ARQUIVO: compartments.tf
# DESCRIÇÃO: Define a criação de compartimentos dentro da tenancy root
#            Os compartimentos PROD e NONPROD serão filhos diretos da
#            tenancy "Nansen Sistemas" (root).
# ====================================================================

# Cria compartimentos dinamicamente a partir de var.compartments
# Filtra apenas os compartimentos que têm parent_ocid == tenancy_ocid
# (ou seja, aqueles que devem ser criados diretamente sob o root)
resource "oci_identity_compartment" "root_level" {
  for_each = {
    for name, config in var.compartments :
    name => config
    if config.parent_ocid == var.tenancy_ocid
  }

  compartment_id = var.tenancy_ocid
  name           = upper(replace(each.key, "-", "_"))
  description    = each.value.description

  lifecycle {
    create_before_destroy = true
  }
}

# Cria compartimentos filhos (aninhados) que dependem de compartimentos raiz criados neste plano
# Usa uma referência ao recurso criado acima como parent
resource "oci_identity_compartment" "child_level" {
  for_each = {
    for name, config in var.compartments :
    name => config
    if config.parent_ocid != var.tenancy_ocid && can(regex("compartment", config.parent_ocid))
  }

  # Extrai o nome do compartimento pai do parent_ocid (formato: "ocid1.compartment.oc1..XXXXX")
  # Assume que há um compartimento raiz com um nome mapeado
  compartment_id = try(
    oci_identity_compartment.root_level[
      [for root_name, root_config in var.compartments :
        root_name if root_config.parent_ocid == var.tenancy_ocid &&
                     config.parent_ocid == oci_identity_compartment.root_level[root_name].id
      ][0]
    ].id,
    config.parent_ocid
  )

  name        = upper(replace(each.key, "-", "_"))
  description = each.value.description

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [oci_identity_compartment.root_level]
}

# ====================================================================
# OUTPUTS: Expõe os IDs dos compartimentos criados para uso em outros recursos
# ====================================================================

output "compartment_ids" {
  description = "Mapa de nomes de compartimentos para seus OCIDs"
  value = merge(
    {
      for name, comp in oci_identity_compartment.root_level :
      name => comp.id
    },
    {
      for name, comp in oci_identity_compartment.child_level :
      name => comp.id
    }
  )
}

output "root_compartments" {
  description = "Compartimentos criados diretamente sob a tenancy root"
  value = {
    for name, comp in oci_identity_compartment.root_level :
    name => {
      id          = comp.id
      name        = comp.name
      parent_ocid = comp.compartment_id
    }
  }
}
