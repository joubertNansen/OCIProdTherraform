
/*
Provider OCI:
 - Configura o provedor da Oracle Cloud Infrastructure com as credenciais
   necessárias e a região. As variáveis usadas aqui vêm de `variables.tf`
   e do arquivo `terraform_prod.tfvars`.
 - tenancy_ocid: OCID da tenancy/conta OCI
 - user_ocid: OCID do usuário que executa as operações
 - fingerprint: fingerprint da chave pública registrada na conta OCI
 - private_key_path: caminho local da chave privada usada para autenticar
 - region: região OCI onde os recursos serão criados
*/
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}


/*
Módulo "infra":
 - O módulo aponta para a raiz do projeto (source = "./"), ou seja, os
   recursos declarados nos arquivos (buckets.tf, instances.tf, etc.) são
   aplicados como parte deste módulo.
 - Os parâmetros (compartments, project_instances, project_buckets, etc.) são
   repassados a partir das variáveis de entrada, permitindo criar recursos
   por projeto de forma parametrizada.
*/
module "infra" {
  source = "./"

  tenancy_ocid      = var.tenancy_ocid
  compartments      = var.compartments
  vcn_cidr          = var.vcn_cidr
  subnet_cidrs      = var.subnet_cidrs
  project_policies  = var.project_policies
  project_instances = var.project_instances
  project_buckets   = var.project_buckets
  project_databases = var.project_databases
}
