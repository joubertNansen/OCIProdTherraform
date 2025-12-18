# Teste de autenticação - apenas leitura
data "oci_identity_compartments" "test" {
  compartment_id = var.tenancy_ocid

  filter {
    name   = "state"
    values = ["ACTIVE"]
  }
}

data "oci_identity_availability_domains" "test" {
  compartment_id = var.tenancy_ocid
}

output "compartments" {
  value = data.oci_identity_compartments.test.compartments
}

output "availability_domains" {
  value = data.oci_identity_availability_domains.test.availability_domains
}