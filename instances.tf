# ====================================================================
# ARQUIVO: instances.tf
# DESCRIÇÃO: Define as máquinas virtuais (instâncias) que rodarão na Oracle Cloud
#            Uma instância é basicamente um computador virtual na nuvem
# ====================================================================

# Recurso: Instância de Computação OCI
# Cria máquinas virtuais (VMs) que podem rodar aplicações, servidores web, etc
# Instância (VM) por projeto
# - Usa for_each para criar instâncias conforme var.project_instances.
# - create_vnic_details define a interface de rede e a subnet onde a VM ficará.
# - source_details define a imagem usada como base para a instância.
# - display_name é um nome legível para a instância.
# - Ajuste shape e image_id conforme necessidade do workload.
data "oci_core_images" "chosen" {
  compartment_id = var.tenancy_ocid
  filter {
    name   = "operating_system"
    values = ["Oracle Linux"]
  }
  sort_by    = "TIMECREATED"
  sort_order = "DESC"
}

# Availability domains data source used to default the availability_domain
# when the instance map doesn't provide one. We default to the first AD in the tenancy.
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

resource "oci_core_instance" "project_instance" {
  for_each = var.project_instances

  # availability_domain should be provided in the instance map
  # If not provided, default to the first availability domain in the tenancy
  availability_domain = lookup(each.value, "availability_domain", "") != "" ? lookup(each.value, "availability_domain", "") : data.oci_identity_availability_domains.ads.availability_domains[0].name

  # Resolve compartment: prefer explicit OCID, else use logical compartment name created by child_level
  compartment_id = lookup(each.value, "compartment_id", "") != "" ? lookup(each.value, "compartment_id", "") : (
    lookup(each.value, "compartment", "") != "" ? (
      contains(keys(oci_identity_compartment.child_level), lookup(each.value, "compartment", "")) ? oci_identity_compartment.child_level[lookup(each.value, "compartment", "")].id : lookup(each.value, "compartment", "")
    ) : local.selected_root_compartment_id
  )

  shape = lookup(each.value, "shape", "VM.Standard2.1")

  create_vnic_details {
    subnet_id = lookup(each.value, "subnet_id", "") != "" ? lookup(each.value, "subnet_id", "") : (
      lookup(each.value, "subnet", "") != "" ? oci_core_subnet.project_subnet[lookup(each.value, "subnet", "")].id : oci_core_subnet.private_shared.id
    )
    # Determine whether to assign a public IP. If user explicitly provided assign_public_ip use it.
    # Otherwise, infer from the project_subnets definition (public=true/false). Default to true for shared subnets.
    assign_public_ip = lookup(each.value, "assign_public_ip", null) != null ? lookup(each.value, "assign_public_ip") : (
      lookup(each.value, "subnet", "") != "" ? lookup(var.project_subnets, lookup(each.value, "subnet", ""), { cidr_block = "", public = true, compartment = "" }).public : true
    )
  }

  source_details {
    source_type = "image"
    # Prefer an explicitly provided image_id. If omitted, choose the first image
    # from the images data source that does NOT contain "aarch64" in its
    # display_name (to avoid selecting ARM-only images when using x86 shapes).
    source_id = lookup(each.value, "image_id", (
      length([for img in data.oci_core_images.chosen.images : img if !can(regex("aarch64|GPU|Gen2", img.display_name))]) > 0 ?
      [for img in data.oci_core_images.chosen.images : img if !can(regex("aarch64|GPU|Gen2", img.display_name))][0].id :
      data.oci_core_images.chosen.images[0].id
    ))
  }

  display_name = "instance-${each.key}"

  # Provide sensible defaults for flexible shapes when user selected a Flex shape
  # This block is only created when the requested shape name contains "Flex".
  dynamic "shape_config" {
    for_each = can(regex("Flex", lookup(each.value, "shape", "VM.Standard.E4.Flex"))) ? [1] : []
    content {
      ocpus         = lookup(each.value, "ocpus", 1)
      memory_in_gbs = lookup(each.value, "memory_in_gbs", 8)
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
