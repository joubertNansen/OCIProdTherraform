# ====================================================================
# MÓDULO: compute
# DESCRIÇÃO: Instâncias de computação para NepenMultilink
# ====================================================================

# Instância para RabbitMQ e serviços auxiliares
resource "oci_core_instance" "rabbitmq_host" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  shape               = var.app_instance_shape

  shape_config {
    ocpus         = var.app_instance_ocpus
    memory_in_gbs = var.app_instance_memory
  }

  create_vnic_details {
    subnet_id        = var.private_subnet_id
    assign_public_ip = false
  }

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_image_id
  }

  display_name = "rabbitmq-host-nepenmultilink"

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.module}/cloud-init-rabbitmq.yaml", {}))
  }

  freeform_tags = {
    Project = "NepenMultilink"
    Role    = "RabbitMQ"
  }
}

# Instância para monitoramento e ferramentas
resource "oci_core_instance" "monitoring_host" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  shape               = var.app_instance_shape

  shape_config {
    ocpus         = var.app_instance_ocpus
    memory_in_gbs = var.app_instance_memory
  }

  create_vnic_details {
    subnet_id        = var.public_subnet_id
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_image_id
  }

  display_name = "monitoring-host-nepenmultilink"

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  freeform_tags = {
    Project = "NepenMultilink"
    Role    = "Monitoring"
  }
}

# Outputs
output "rabbitmq_host_private_ip" {
  value = oci_core_instance.rabbitmq_host.private_ip
}

output "monitoring_host_public_ip" {
  value = oci_core_instance.monitoring_host.public_ip
}

output "app_instances" {
  value = [
    {
      instance_id = oci_core_instance.monitoring_host.id
      ip_address  = oci_core_instance.monitoring_host.private_ip
    }
  ]
}