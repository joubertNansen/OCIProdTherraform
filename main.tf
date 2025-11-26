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
Módulo "infra" removido: evitar referência recursiva ao diretório raiz.
Os recursos existentes na raiz (vcn.tf, buckets.tf, instances.tf, etc.)
serão aplicados diretamente sem encapsular a raiz como um módulo.
*/
