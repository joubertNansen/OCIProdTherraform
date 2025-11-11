
/*
Recurso: Instância (VM) por projeto
 - Usa `for_each` para criar instâncias conforme var.project_instances.
 - `create_vnic_details` define a interface de rede e a subnet onde a VM ficará.
 - `source_details` define a imagem usada como base para a instância.
 - `display_name` é um nome legível para a instância.
 - Ajuste `shape` e `image_id` conforme necessidade do workload.
*/
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
