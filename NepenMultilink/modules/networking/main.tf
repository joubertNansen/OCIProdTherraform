# ====================================================================
# MÓDULO: networking
# DESCRIÇÃO: VCN, subnets, gateways e security lists para NepenMultilink
# ====================================================================

# VCN
resource "oci_core_virtual_network" "vcn" {
  compartment_id = var.compartment_id
  display_name   = "vcn-nepenmultilink"
  cidr_block     = var.vcn_cidr
}

# Internet Gateway
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "igw-nepenmultilink"
  enabled        = true
}

# NAT Gateway
resource "oci_core_nat_gateway" "nat" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "nat-nepenmultilink"
}

# Service Gateway
data "oci_core_services" "all_services" {}

resource "oci_core_service_gateway" "sgw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "sgw-nepenmultilink"
  services {
    service_id = data.oci_core_services.all_services.services[0].id
  }
}

# Route Tables
resource "oci_core_route_table" "rt_public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "rt-public-nepenmultilink"

  route_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

resource "oci_core_route_table" "rt_private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "rt-private-nepenmultilink"

  route_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat.id
  }

  route_rules {
    destination      = data.oci_core_services.all_services.services[0].cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sgw.id
  }
}

# Subnets
resource "oci_core_subnet" "public" {
  compartment_id               = var.compartment_id
  vcn_id                       = oci_core_virtual_network.vcn.id
  display_name                 = "subnet-public-nepenmultilink"
  cidr_block                   = var.public_subnet_cidr
  prohibit_public_ip_on_vnic   = false
  route_table_id               = oci_core_route_table.rt_public.id
  security_list_ids            = [oci_core_security_list.public_sl.id]
}

resource "oci_core_subnet" "private" {
  compartment_id               = var.compartment_id
  vcn_id                       = oci_core_virtual_network.vcn.id
  display_name                 = "subnet-private-nepenmultilink"
  cidr_block                   = var.private_subnet_cidr
  prohibit_public_ip_on_vnic   = true
  route_table_id               = oci_core_route_table.rt_private.id
  security_list_ids            = [oci_core_security_list.private_sl.id]
}

# Security Lists
resource "oci_core_security_list" "public_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "sl-public-nepenmultilink"

  # Ingress - SSH
  ingress_security_rules {
    protocol = "6"  # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Ingress - HTTP/HTTPS
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }

  # Egress - All
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "private_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "sl-private-nepenmultilink"

  # Ingress - From VCN
  ingress_security_rules {
    protocol = "6"
    source   = var.vcn_cidr
  }

  # Ingress - SSH from public subnet
  ingress_security_rules {
    protocol = "6"
    source   = var.public_subnet_cidr
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Egress - All
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

# Outputs
output "vcn_id" {
  value = oci_core_virtual_network.vcn.id
}

output "public_subnet_id" {
  value = oci_core_subnet.public.id
}

output "private_subnet_id" {
  value = oci_core_subnet.private.id
}