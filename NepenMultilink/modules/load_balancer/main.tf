# ====================================================================
# MÓDULO: load_balancer
# DESCRIÇÃO: Load Balancer para microsserviços NepenMultilink
# ====================================================================

# Load Balancer
resource "oci_load_balancer_load_balancer" "lb" {
  compartment_id             = var.compartment_id
  display_name               = "lb-nepenmultilink"
  shape                      = "flexible"
  shape_details {
    maximum_bandwidth_in_mbps = 100
    minimum_bandwidth_in_mbps = 10
  }
  subnet_ids                 = var.subnet_ids
  is_private                 = false

  freeform_tags = {
    Project = "NepenMultilink"
  }
}

# Backend Set para API Gateway
resource "oci_load_balancer_backend_set" "api_backend_set" {
  load_balancer_id = oci_load_balancer_load_balancer.lb.id
  name             = "api-backend-set"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol = "HTTP"
    port     = 80
    url_path = "/actuator/health"
  }
}

# Listener HTTP
resource "oci_load_balancer_listener" "http_listener" {
  load_balancer_id         = oci_load_balancer_load_balancer.lb.id
  name                     = "http-listener"
  default_backend_set_name = oci_load_balancer_backend_set.api_backend_set.name
  port                     = 80
  protocol                 = "HTTP"
}

# Listener HTTPS
resource "oci_load_balancer_listener" "https_listener" {
  load_balancer_id         = oci_load_balancer_load_balancer.lb.id
  name                     = "https-listener"
  default_backend_set_name = oci_load_balancer_backend_set.api_backend_set.name
  port                     = 443
  protocol                 = "HTTP"

  ssl_configuration {
    certificate_name = oci_load_balancer_certificate.certificate.certificate_name
    verify_peer_certificate = false
  }
}

# Certificate (placeholder - seria configurado com certificado real)
resource "oci_load_balancer_certificate" "certificate" {
  load_balancer_id = oci_load_balancer_load_balancer.lb.id
  certificate_name = "nepenmultilink-cert"

  # Em produção, usar public_certificate e private_key
  # ou integrar com OCI Certificates
  ca_certificate     = ""  # Placeholder
  public_certificate = file("caminho/do/certificado.pem")
  private_key        = file("caminho/do/private_key.pem")
}

# Backends dinâmicos baseados nas instâncias passadas
resource "oci_load_balancer_backend" "backends" {
  for_each = { for idx, instance in var.backend_set_instances : idx => instance }

  load_balancer_id = oci_load_balancer_load_balancer.lb.id
  backendset_name  = oci_load_balancer_backend_set.api_backend_set.name
  ip_address       = each.value.ip_address
  port             = 8080
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# Outputs
output "load_balancer_ip" {
  value = oci_load_balancer_load_balancer.lb.ip_address_details[0].ip_address
}