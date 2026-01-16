# ====================================================================
# MÓDULO: oke
# DESCRIÇÃO: Oracle Container Engine for Kubernetes para microsserviços
# ====================================================================

# OKE Cluster
resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = var.compartment_id
  kubernetes_version = "v1.28.2"
  name               = "oke-nepenmultilink"
  vcn_id             = var.vcn_id

  options {
    service_lb_subnet_ids = [var.subnet_id]
  }

  freeform_tags = {
    Project = "NepenMultilink"
  }
}

# Node Pool
resource "oci_containerengine_node_pool" "node_pool" {
  cluster_id         = oci_containerengine_cluster.oke_cluster.id
  compartment_id     = var.compartment_id
  kubernetes_version = "v1.28.2"
  name               = "node-pool-nepenmultilink"

  node_config_details {
    placement_configs {
      availability_domain = var.availability_domain
      subnet_id           = var.subnet_id
    }

    size = 3

    node_pool_pod_network_option_details {
      cni_type = "FLANNEL_OVERLAY"
    }
  }

  node_shape = "VM.Standard.E4.Flex"

  node_shape_config {
    ocpus         = 2
    memory_in_gbs = 30
  }

  node_source_details {
    image_id    = var.node_image_id
    source_type = "IMAGE"
  }

  freeform_tags = {
    Project = "NepenMultilink"
  }
}

# Outputs
output "cluster_id" {
  value = oci_containerengine_cluster.oke_cluster.id
}

output "cluster_endpoints" {
  value = oci_containerengine_cluster.oke_cluster.endpoints
}

output "node_pool_id" {
  value = oci_containerengine_node_pool.node_pool.id
}