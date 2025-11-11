/*
Arquivo: variables.tf (anotado)
Propósito: declarações das variáveis que parametram o módulo/infraestrutura.

Cada variável possui tipo e, quando aplicável, valores default. Comentários em
português explicam a finalidade de cada variável.
*/

/* Credenciais e região */
variable "tenancy_ocid" { type = string }         # OCID da tenancy
variable "user_ocid" { type = string }            # OCID do usuário que vai operar
variable "fingerprint" { type = string }          # Fingerprint da chave pública
variable "private_key_path" { type = string }     # Caminho para a chave privada (para o provider OCI)
variable "region" { type = string }               # Região OCI

/* Compartimentos (compartments) */
variable "compartments" {
  # Mapa onde a chave é o nome lógico do compartment e o valor é um objeto
  # contendo descrição e parent_ocid (OCID do compartimento pai/tenancy)
  type = map(object({ description = string, parent_ocid = string }))
  default = {}
}

/* Rede (VCN e subnets) */
variable "vcn_cidr" { type = string, default = "10.0.0.0/16" }
variable "subnet_cidrs" {
  type = map(string)
  default = {
    public  = "10.0.1.0/24",
    private = "10.0.2.0/24"
  }
}

/* Políticas IAM por projeto */
variable "project_policies" {
  # Mapa de políticas onde cada valor é um objeto com compartment_id e lista de statements
  type = map(object({ compartment_id = string, statements = list(string) }))
  default = {}
}

/* Instâncias por projeto */
variable "project_instances" {
  # Estrutura que define os parâmetros necessários para criar instâncias
  type = map(object({
    availability_domain = string,
    compartment_id      = string,
    shape               = string,
    subnet_id           = string,
    image_id            = string
  }))
  default = {}
}

/* Buckets (Object Storage) por projeto */
variable "project_buckets" {
  type = map(object({ compartment_id = string, namespace = string }))
  default = {}
}

/* Bancos de dados (DB systems) por projeto */
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
