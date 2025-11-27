# ====================================================================
# ARQUIVO: vcn.tf
# DESCRIÇÃO: Cria VCN e subnets públicas/privadas compartilhadas para PROD
#            Recursos criados dentro do compartimento `shared-network-prod`
# ====================================================================

data "oci_core_services" "all_services" {}

resource "oci_core_virtual_network" "vcn_shared" {
  compartment_id = oci_identity_compartment.root_level["prod"].id
  display_name   = "SHARED-VCN-PROD"
  cidr_block     = var.vcn_cidr

  lifecycle {
    create_before_destroy = true
  }
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = oci_identity_compartment.root_level["prod"].id
  vcn_id         = oci_core_virtual_network.vcn_shared.id
  display_name   = "IGW-SHARED-PROD"
  enabled        = true
}

resource "oci_core_nat_gateway" "nat" {
  compartment_id = oci_identity_compartment.root_level["prod"].id
  vcn_id         = oci_core_virtual_network.vcn_shared.id
  display_name   = "NAT-SHARED-PROD"
}

resource "oci_core_service_gateway" "sgw" {
  compartment_id = oci_identity_compartment.root_level["prod"].id
  vcn_id         = oci_core_virtual_network.vcn_shared.id
  display_name   = "SGW-SHARED-PROD"
  services {
    service_id = data.oci_core_services.all_services.services[0].id
  }
}

resource "oci_core_route_table" "rt_public" {
  compartment_id = oci_identity_compartment.root_level["prod"].id
  vcn_id         = oci_core_virtual_network.vcn_shared.id
  display_name   = "RT-PUBLIC-SHARED-PROD"

  route_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

resource "oci_core_route_table" "rt_private" {
  compartment_id = oci_identity_compartment.root_level["prod"].id
  vcn_id         = oci_core_virtual_network.vcn_shared.id
  display_name   = "RT-PRIVATE-SHARED-PROD"

  route_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat.id
  }

  # Rota opcional para Service Gateway
  # Ativada apenas quando `var.enable_service_gateway_routes` for true e
  # `var.service_gateway_destination` estiver preenchido (evita destination inválido)
  dynamic "route_rules" {
    for_each = var.enable_service_gateway_routes && length(trim(var.service_gateway_destination)) > 0 ? [1] : []
    content {
      destination      = var.service_gateway_destination
      destination_type = var.service_gateway_destination_type
      network_entity_id = oci_core_service_gateway.sgw.id
    }
  }
}

resource "oci_core_subnet" "public_shared" {
  compartment_id               = oci_identity_compartment.root_level["prod"].id
  vcn_id                       = oci_core_virtual_network.vcn_shared.id
  display_name                 = "subnet-pub-shared"
  cidr_block                   = var.subnet_cidrs["public"]
  prohibit_public_ip_on_vnic   = false
  route_table_id               = oci_core_route_table.rt_public.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "oci_core_subnet" "private_shared" {
  compartment_id               = oci_identity_compartment.root_level["prod"].id
  vcn_id                       = oci_core_virtual_network.vcn_shared.id
  display_name                 = "subnet-priv-shared"
  cidr_block                   = var.subnet_cidrs["private"]
  prohibit_public_ip_on_vnic   = true
  route_table_id               = oci_core_route_table.rt_private.id

  lifecycle {
    create_before_destroy = true
  }
}

# --- Subnets dedicadas por projeto (opcionais) ---
// Subnets dedicadas por projeto (opcionais) - criadas somente se `var.enable_project_subnets` for true
resource "oci_core_subnet" "project_subnet" {
  for_each = var.enable_project_subnets ? var.project_subnets : {}

  compartment_id = oci_identity_compartment.child_level[each.value.compartment].id
  vcn_id         = oci_core_virtual_network.vcn_shared.id
  display_name   = "subnet-${each.key}"
  cidr_block     = each.value.cidr_block
  prohibit_public_ip_on_vnic = !each.value.public
  route_table_id = each.value.public ? oci_core_route_table.rt_public.id : oci_core_route_table.rt_private.id

  lifecycle {
    create_before_destroy = true
  }
}

output "vcn_shared_id" {
  value = oci_core_virtual_network.vcn_shared.id
}

output "pub_subnet_shared_id" {
  value = oci_core_subnet.public_shared.id
}

output "priv_subnet_shared_id" {
  value = oci_core_subnet.private_shared.id
}

output "project_subnet_ids" {
  description = "IDs das subnets por projeto (se `enable_project_subnets` estiver ativo)"
  value = var.enable_project_subnets ? {
    for name, s in oci_core_subnet.project_subnet : name => s.id
  } : {}
}
