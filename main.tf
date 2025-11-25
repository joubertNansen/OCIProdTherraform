# ====================================================================
# ARQUIVO: main.tf
# DESCRIÇÃO: Arquivo principal do Terraform que configura o provedor OCI
#            (Oracle Cloud Infrastructure) e organiza toda a infraestrutura
#            através de um módulo local reutilizável
# ====================================================================

# Configuração do Provedor OCI
# Define como o Terraform vai se conectar e autenticar na Oracle Cloud
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
  tenancy_ocid     = var.tenancy_ocid # tenancy_ocid: Identificador único do inquilino (conta) OCI
  user_ocid        = var.user_ocid # user_ocid: Identificador único do usuário OCI que está fazendo a autenticação
  fingerprint      = var.fingerprint # fingerprint: Impressão digital da chave pública para autenticação API
  private_key_path = var.private_key_path # private_key_path: Caminho local do arquivo da chave privada usada na autenticação
  region           = var.region # region: Região geográfica do OCI onde os recursos serão criados (ex: São Paulo)
}


# Módulo de Infraestrutura
# Agrupa toda a configuração de recursos (redes, máquinas, bancos de dados, etc.)
# Usar módulos facilita a reutilização e manutenção do código
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
      # source: Aponta para a pasta atual (./), onde estão os arquivos de recursos
  source = "./"
      # Passa todas as variáveis para o módulo processar e criar os recursos
  tenancy_ocid      = var.tenancy_ocid
  compartments      = var.compartments
  vcn_cidr          = var.vcn_cidr
  subnet_cidrs      = var.subnet_cidrs
  project_policies  = var.project_policies
  project_instances = var.project_instances
  project_buckets   = var.project_buckets
  project_databases = var.project_databases
}
