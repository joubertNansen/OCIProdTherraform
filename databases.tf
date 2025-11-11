
/*
Recurso: DB System (banco de dados gerenciado) por projeto
 - `for_each` permite criar um DB system para cada entrada em var.project_databases.
 - Atenção: admin_password é sensível; preferir passar via mecanismo seguro
   (secrets manager) em ambientes reais.
*/
resource "oci_database_db_system" "project_db" {
  for_each = var.project_databases

  availability_domain = each.value.availability_domain
  compartment_id      = each.value.compartment_id
  shape               = each.value.shape
  subnet_id           = each.value.subnet_id
  database_edition    = each.value.database_edition

  db_home {
    database {
      db_name         = each.value.db_name
      admin_password  = each.value.admin_password
    }
  }
}
