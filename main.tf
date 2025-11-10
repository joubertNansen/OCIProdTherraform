
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

module "infra" {
  source = "./"

  tenancy_ocid     = var.tenancy_ocid
  compartments     = var.compartments
  vcn_cidr         = var.vcn_cidr
  subnet_cidrs     = var.subnet_cidrs
  project_policies = var.project_policies
  project_instances = var.project_instances
  project_buckets   = var.project_buckets
  project_databases = var.project_databases
}
