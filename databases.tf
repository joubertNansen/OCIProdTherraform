# ====================================================================
# ARQUIVO: databases.tf
# DESCRIÇÃO: Define os bancos de dados que rodarão na Oracle Cloud
#            Usa o Oracle Database ou MySQL Database Service
# ====================================================================

# Recurso: Sistema de Banco de Dados OCI
# Cria um servidor de banco de dados completo (hardware + software + rede)
/*
Recurso: DB System (banco de dados gerenciado) por projeto
 - `for_each` permite criar um DB system para cada entrada em var.project_databases.
 - Atenção: admin_password é sensível; preferir passar via mecanismo seguro
   (secrets manager) em ambientes reais.
*/
/*
resource "oci_database_db_system" "project_db" {
  for_each = var.project_databases # for_each: Cria um banco de dados para cada projeto definido em var.project_databases
  availability_domain = each.value.availability_domain # availability_domain: Zona de disponibilidade onde o BD será criado
  compartment_id = each.value.compartment_id # compartment_id: ID do compartimento onde o BD será criado e gerenciado
  shape = each.value.shape # shape: Tipo e tamanho da máquina que hospedará o BD
  subnet_id = each.value.subnet_id # subnet_id: ID da sub-rede (rede privada) onde o BD será conectado
  database_edition  = each.value.database_edition

  db_home {
    database {
      db_name = each.value.db_name
      admin_password  = each.value.admin_password
    }
  }
}
*/
