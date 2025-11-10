
variable "tenancy_ocid" { type = string }
variable "user_ocid" { type = string }
variable "fingerprint" { type = string }
variable "private_key_path" { type = string }
variable "region" { type = string }

variable "compartments" {
  type = map(object({ description = string, parent_ocid = string }))
  default = {}
}

variable "vcn_cidr" { type = string, default = "10.0.0.0/16" }
variable "subnet_cidrs" {
  type = map(string)
  default = {
    public  = "10.0.1.0/24",
    private = "10.0.2.0/24"
  }
}

variable "project_policies" {
  type = map(object({ compartment_id = string, statements = list(string) }))
  default = {}
}

variable "project_instances" {
  type = map(object({
    availability_domain = string,
    compartment_id      = string,
    shape               = string,
    subnet_id           = string,
    image_id            = string
  }))
  default = {}
}

variable "project_buckets" {
  type = map(object({ compartment_id = string, namespace = string }))
  default = {}
}

variable "project_databases" {
  type = map(object({
    availability_domain = string,
    compartment_id      = string,
    shape               = string,
    subnet_id           = string,
    database_edition    = string,
    db_name             = string,
    admin_password      = string
  }))
  default = {}
}
