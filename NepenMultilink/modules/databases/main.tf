# ====================================================================
# MÓDULO: databases
# DESCRIÇÃO: Bancos de dados para NepenMultilink (PostgreSQL, MongoDB, Redis)
# ALTERAÇÃO: Usando instâncias Compute para reduzir custos significativamente
# ====================================================================

# Instância Compute para PostgreSQL (TimescaleDB)
resource "oci_core_instance" "postgresql" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  shape               = var.db_shape

  shape_config {
    ocpus         = var.db_ocpus
    memory_in_gbs = var.db_memory
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = false
  }

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_image_id
  }

  display_name = "postgresql-host-nepenmultilink"

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.module}/cloud-init-postgresql.yaml", {
      admin_password = var.db_admin_password
    }))
  }

  freeform_tags = {
    Project = "NepenMultilink"
    Type    = "PostgreSQL"
  }
}

# Instância Compute para MongoDB
resource "oci_core_instance" "mongodb" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  shape               = var.mongodb_shape

  shape_config {
    ocpus         = var.mongodb_ocpus
    memory_in_gbs = var.mongodb_memory
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = false
  }

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_image_id
  }

  display_name = "mongodb-host-nepenmultilink"

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.module}/cloud-init-mongodb.yaml", {
      admin_password = var.mongodb_admin_password
    }))
  }

  freeform_tags = {
    Project = "NepenMultilink"
    Type    = "MongoDB"
  }
}

# OCI Cache (Redis) - Mantido pois já é econômico
resource "oci_cache_redis_cluster" "redis" {
  compartment_id     = var.compartment_id
  display_name       = "Redis-NepenMultilink"
  node_count         = 1
  node_memory_in_gbs = 30
  subnet_id          = var.subnet_id

  freeform_tags = {
    Project = "NepenMultilink"
    Type    = "Redis"
  }
}

# Outputs
output "postgresql_private_ip" {
  value = oci_core_instance.postgresql.private_ip
}

output "mongodb_private_ip" {
  value = oci_core_instance.mongodb.private_ip
}

output "redis_primary_endpoint" {
  value = oci_cache_redis_cluster.redis.primary_endpoint_ip_address
}