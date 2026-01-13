# ====================================================================
# ARQUIVO: instances.tf
# DESCRIÇÃO: Define as máquinas virtuais (instâncias) que rodarão na Oracle Cloud
#            Uma instância é basicamente um computador virtual na nuvem
# ====================================================================

# Recurso: Instância de Computação OCI
# Cria máquinas virtuais (VMs) que podem rodar aplicações, servidores web, etc

# Recurso: Instância (VM) por projeto
# - Usa `for_each` para criar instâncias conforme var.project_instances.
# - `create_vnic_details` define a interface de rede e a subnet onde a VM ficará.
# - `source_details` define a imagem usada como base para a instância.
# - `display_name` é um nome legível para a instância.
# - Ajuste `shape` e `image_id` conforme necessidade do workload.

resource "oci_core_instance" "project_instance" {
  for_each = var.project_instances # for_each: Cria uma VM para cada projeto definido em var.project_instances
  availability_domain = each.value.availability_domain # availability_domain: Zona de disponibilidade (data center) onde a VM será criada   # Usar diferentes zonas garante redundância e alta disponibilidade
  compartment_id      = each.value.compartment_id # compartment_id: ID do compartimento onde a VM será criada e gerenciada
  shape               = each.value.shape # shape: Tipo e tamanho da máquina (processador, RAM, etc)  # Exemplos: VM.Standard.E4.Flex (processador flexível), VM.Standard2.1 (menor)

  # Configuração de Interface de Rede Virtual (VNIC)
  # Define como a VM se conecta à rede
  create_vnic_details { 
    # subnet_id: ID da sub-rede (rede virtual) onde a VM será conectada
    subnet_id        = each.value.subnet_id
    assign_public_ip = true
  }

  # Configuração da Origem da VM
  # Define qual imagem (SO + software) será usada para criar a VM
  source_details {
    source_type = "image"             # Tipo de origem ("image" = usar uma imagem de SO)
    source_id   = each.value.image_id # ID da imagem a usar (ex: imagem Ubuntu Linux, Windows Server, etc)
  }
 
  display_name = "instance-${each.key}"  # display_name: Nome amigável exibido no console do OCI
}
