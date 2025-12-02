```terraform
/*
Arquivo: main.tf (anotado)
Propósito: configura o provider OCI e instancia um módulo local que cria a infraestrutura.

Comentários em português explicando cada bloco.
*/

/*
provider "oci":
 - Configura o provedor da Oracle Cloud Infrastructure (OCI) com as credenciais
   e a região que estão sendo passadas via variáveis.
 - Os campos (tenancy_ocid, user_ocid, fingerprint, private_key_path, region)
   devem ser definidos no arquivo de variáveis ou tfvars (ex.: terraform_nonprod.tfvars).
*/
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid      # OCID da tenancy (conta) na OCI
  user_ocid        = var.user_ocid         # OCID do usuário que executa o Terraform
  fingerprint      = var.fingerprint       # Fingerprint da chave pública usada
  private_key_path = var.private_key_path  # Caminho para a chave privada (ex.: ~/.oci/nonprod_api_key.pem)
  region           = var.region            # Região onde os recursos serão criados
}

/*
Módulo "infra":
 - Neste repositório o módulo fonte é a raiz do módulo ("./"), indicando que
   os recursos (buckets.tf, instances.tf etc.) serão aplicados com os dados
   fornecidos pelas variáveis.
 - Os inputs do módulo são repassados a partir das variáveis definidas no root.
*/
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
```
