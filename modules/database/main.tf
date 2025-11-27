variable "compartment_id" {}
variable "display_name" { default = "autonomous-db" }

locals {
  note = "Fill this module with database resources like oci_database_autonomous_database"
}
