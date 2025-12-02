# ====================================================================
# ARQUIVO: vcn.tf
# DESCRIÇÃO: Cria VCN e subnets públicas/privadas compartilhadas para NONPROD
#            Recursos criados dentro do compartimento `shared-network-nonprod`
# ====================================================================

data "oci_core_services" "all_services" {}

# Local helper to pick the correct root compartment id for this environment.
# Uses `var.environment` when present in the map, otherwise falls back to the
# first entry in `oci_identity_compartment.root_level` so the code is tolerant
# when only one key exists (eg: prod only).
locals {
  root_compartments = oci_identity_compartment.root_level
  selected_root_compartment_id = contains(keys(local.root_compartments), var.environment) ? local.root_compartments[var.environment].id : values(local.root_compartments)[0].id
}

resource "oci_core_virtual_network" "vcn_shared" {
  compartment_id = local.selected_root_compartment_id
  display_name   = "SHARED-VCN-${upper(var.environment)}"
  cidr_block     = var.vcn_cidr

  lifecycle {
    create_before_destroy = true
  }
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = local.selected_root_compartment_id
  vcn_id         = oci_core_virtual_network.vcn_shared.id
  display_name   = "IGW-SHARED-${upper(var.environment)}"
  enabled        = true
}

resource "oci_core_nat_gateway" "nat" {
  compartment_id = local.selected_root_compartment_id
  vcn_id         = oci_core_virtual_network.vcn_shared.id
  display_name   = "NAT-SHARED-${upper(var.environment)}"
}

resource "oci_core_service_gateway" "sgw" {
  compartment_id = local.selected_root_compartment_id
  vcn_id         = oci_core_virtual_network.vcn_shared.id
  display_name   = "SGW-SHARED-${upper(var.environment)}"
  services {
    service_id = data.oci_core_services.all_services.services[0].id
  }
}

resource "oci_core_route_table" "rt_public" {
  compartment_id = local.selected_root_compartment_id
  vcn_id         = oci_core_virtual_network.vcn_shared.id
  display_name   = "RT-PUBLIC-SHARED-${upper(var.environment)}"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

resource "oci_core_route_table" "rt_private" {
  compartment_id = local.selected_root_compartment_id
  vcn_id         = oci_core_virtual_network.vcn_shared.id
  display_name   = "RT-PRIVATE-SHARED-${upper(var.environment)}"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat.id
  }

  # Rota opcional para Service Gateway
  # Ativada apenas quando `var.enable_service_gateway_routes` for true e
  # `var.service_gateway_destination` estiver preenchido (evita destination inválido)
  dynamic "route_rules" {
    for_each = var.enable_service_gateway_routes && length(trim(var.service_gateway_destination)) > 0 ? [1] : []
    content {
      destination       = var.service_gateway_destination
      destination_type  = var.service_gateway_destination_type
      network_entity_id = oci_core_service_gateway.sgw.id
    }
  }
}

resource "oci_core_subnet" "public_shared" {
  compartment_id             = local.selected_root_compartment_id
  vcn_id                     = oci_core_virtual_network.vcn_shared.id
  display_name               = "subnet-pub-shared-${lower(var.environment)}"
  cidr_block                 = var.subnet_cidrs["public"]
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.rt_public.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "oci_core_subnet" "private_shared" {
  compartment_id             = local.selected_root_compartment_id
  vcn_id                     = oci_core_virtual_network.vcn_shared.id
  display_name               = "subnet-priv-shared-${lower(var.environment)}"
  cidr_block                 = var.subnet_cidrs["private"]
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.rt_private.id

  lifecycle {
    create_before_destroy = true
  }
}

// Subnets dedicadas por projeto (opcionais) - criadas somente se `var.enable_project_subnets` for true
resource "oci_core_subnet" "project_subnet" {
  for_each = var.enable_project_subnets ? var.project_subnets : {}

  compartment_id             = oci_identity_compartment.child_level[each.value.compartment].id
  vcn_id                     = oci_core_virtual_network.vcn_shared.id
  display_name               = "subnet-${each.key}"
  cidr_block                 = each.value.cidr_block
  prohibit_public_ip_on_vnic = !each.value.public
  route_table_id             = each.value.public ? oci_core_route_table.rt_public.id : oci_core_route_table.rt_private.id

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
