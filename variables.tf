
/*
Arquivo: variables.tf
Finalidade: declaração das variáveis que parametrizam a infra.

As variáveis permitem reaproveitar os recursos para múltiplos projetos e
ambientes (ex.: dev, staging, prod). Muitos valores sensíveis (chaves,
senhas) são passados através de arquivos tfvars ou via variáveis de ambiente.
*/

/* Credenciais e região (usadas pelo provider OCI) */
variable "tenancy_ocid" { type = string }       # OCID da tenancy/conta OCI
variable "user_ocid" { type = string }          # OCID do usuário
variable "fingerprint" { type = string }        # Fingerprint da chave pública
variable "private_key_path" { type = string }   # Caminho para a chave privada (ex.: ~/.oci/key.pem)
variable "region" { type = string }             # Região OCI (ex.: sa-saopaulo-1)


/* Compartimentos (compartments) */
variable "compartments" {
  # Mapa onde a chave é o nome lógico do compartimento e o valor é um objeto
  # com descrição e parent_ocid (OCID do compartimento pai ou tenancy).
  type = map(object({ description = string, parent_ocid = string }))
  default = {}
}


/* Rede (VCN e subnets) */
variable "vcn_cidr" { type = string, default = "10.0.0.0/16" }
variable "subnet_cidrs" {
  # Mapa com os CIDRs das subnets públicas e privadas. Pode ser sobrescrito
  # no arquivo tfvars para cada ambiente.
  type = map(string)
  default = {
    public  = "10.0.1.0/24",
    private = "10.0.2.0/24"
  }
}


/* Políticas IAM por projeto */
variable "project_policies" {
  # Mapa onde cada entrada define um policy resource para um projeto.
  # Cada valor contém o compartment_id onde a policy será criada e uma lista
  # de statements (strings) que representam as regras da política.
  type = map(object({ compartment_id = string, statements = list(string) }))
  default = {}
}


/* Instâncias (VMs) por projeto */
variable "project_instances" {
  # Mapa de instâncias, cada valor especifica parâmetros necessários para
  # criar uma instância (availability domain, shape, image, subnet, etc.).
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
  # Mapa com configuração de buckets: compartment_id e namespace do object storage
  type = map(object({ compartment_id = string, namespace = string }))
  default = {}
}


/* Bancos de dados (DB systems) por projeto */
variable "project_databases" {
  # Mapa com parâmetros para criar DB systems. Contém informações sensíveis
  # como admin_password — evite commitar senhas em texto claro no repositório.
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

