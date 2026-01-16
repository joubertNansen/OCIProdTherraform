# ====================================================================
# PROJETO: NepenMultilink Infrastructure
# DESCRIÇÃO: Infraestrutura OCI para aplicação NEPENMULTILINK
# ARQUITETURA: Microsserviços com bancos PostgreSQL, MongoDB, Redis e RabbitMQ
# ====================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

# Provider OCI
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# Módulos
module "networking" {
  source = "./modules/networking"
  compartment_id = var.compartment_id
  vcn_cidr = var.vcn_cidr
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "databases" {
  source = "./modules/databases"
  compartment_id = var.compartment_id
  subnet_id = module.networking.private_subnet_id
  availability_domain = var.availability_domain
}

module "compute" {
  source = "./modules/compute"
  compartment_id = var.compartment_id
  public_subnet_id = module.networking.public_subnet_id
  private_subnet_id = module.networking.private_subnet_id
  availability_domain = var.availability_domain
}

module "oke" {
  source = "./modules/oke"
  compartment_id = var.compartment_id
  vcn_id = module.networking.vcn_id
  subnet_id = module.networking.private_subnet_id
  availability_domain = var.availability_domain
}

module "load_balancer" {
  source = "./modules/load_balancer"
  compartment_id = var.compartment_id
  subnet_ids = [module.networking.public_subnet_id]
  backend_set_instances = module.compute.app_instances
}