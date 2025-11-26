
/*
Arquivo: variables.tf
Finalidade: declaração das variáveis que parametrizam a infra.

As variáveis permitem reaproveitar os recursos para múltiplos projetos e
ambientes (ex.: dev, staging, prod). Muitos valores sensíveis (chaves,
senhas) são passados através de arquivos tfvars ou via variáveis de ambiente.
*/

# ---- VARIÁVEIS DE AUTENTICAÇÃO (Obrigatórias) ----

/* Credenciais e região (usadas pelo provider OCI) */
variable "tenancy_ocid" { type = string }       # # Identificador único do inquilino (conta) na Oracle Cloud
variable "user_ocid" { type = string }          # Identificador do usuário que tem permissão para criar recursos
variable "fingerprint" { type = string }        # Impressão digital da chave pública usada na autenticação API
variable "private_key_path" { type = string }   # Caminho do arquivo contendo a chave privada para autenticação (ex.: ~/.oci/key.pem)
variable "region" { type = string }             # Região do OCI onde os recursos serão criados (ex: "sa-saopaulo-1")

# ---- VARIÁVEIS DE REDE ----

# Compartimentos: Divisões lógicas dentro da conta OCI para organizar recursos
# Cada compartimento tem seu próprio escopo de segurança e acesso
variable "compartments" {
      # Mapa onde a chave é o nome lógico do compartimento e o valor é um objeto
      # com descrição e parent_ocid (OCID do compartimento pai ou tenancy).
  type = map(object({
    description = string, # Descrição do compartimento
    parent_ocid = string  # OCID do compartimento pai/raiz
    }))
  default = {}
}

/* Rede (VCN e subnets) */
# CIDR (Classless Inter-Domain Routing) da Rede Virtual (VCN)
# Define a faixa de endereços IP disponíveis (10.0.0.0/16 = 65.536 IPs)
variable "vcn_cidr" {
 type = string, 
 default = "10.0.0.0/16"
}

# Sub-redes (subnets): Divisões da VCN em faixas IP menores
# public: para recursos expostos à internet
# private: para recursos sem acesso direto à internet
variable "subnet_cidrs" {
      # Mapa com os CIDRs das subnets públicas e privadas. Pode ser sobrescrito
      # no arquivo tfvars para cada ambiente.
  type = map(string)
  default = {
    public  = "10.0.1.0/24",
    private = "10.0.2.0/24"
  }
}

# ---- SUBNETS DEDICADAS POR PROJETO ----
# Permite declarar subnets dedicadas para projetos específicos quando necessário
variable "project_subnets" {
  type = map(object({
    cidr_block  = string,
    public      = bool,
    compartment = string
  }))
  default = {}
}

# ---- VARIÁVEIS DE CONTROLE DE ACESSO (IAM) ----

/* Políticas IAM por projeto */
# Políticas de permissão: Definem quem pode fazer o quê em cada compartimento
variable "project_policies" {
      # Mapa onde cada entrada define um policy resource para um projeto.
      # Cada valor contém o compartment_id onde a policy será criada e uma lista
      # de statements (strings) que representam as regras da política.
  type = map(object({
    compartment_id = string,  # Compartimento onde a política se aplica
    statements = list(string)  # Regras de permissão (Allow/Deny)
    }))
  default = {}
}

# ---- VARIÁVEIS DE MÁQUINAS VIRTUAIS ----

/* Instâncias (VMs) por projeto */
# Instâncias: Máquinas virtuais que rodam na Oracle Cloud
variable "project_instances" {
      # Mapa de instâncias, cada valor especifica parâmetros necessários para
      # criar uma instância (availability domain, shape, image, subnet, etc.).
  type = map(object({
    availability_domain = string, # Zona de disponibilidade (para redundância)
    compartment_id      = string, # Compartimento onde a VM será criada
    shape               = string, # Tipo/tamanho da VM (ex: VM.Standard.E4.Flex)
    subnet_id           = string, # Sub-rede onde a VM será conectada
    image_id            = string  # Imagem do SO (Linux, Windows, etc)
  }))
  default = {}
}

# ---- VARIÁVEIS DE ARMAZENAMENTO ----

/* Buckets (Object Storage) por projeto */
# Buckets: Armazenamento em nuvem para arquivos (similar ao S3 da AWS)
variable "project_buckets" {
      # Mapa com configuração de buckets: compartment_id e namespace do object storage
  type = map(object({
    compartment_id = string, 
    namespace = string 
   }))
  default = {}
}

# ---- VARIÁVEIS DE BANCO DE DADOS ----

/* Bancos de dados (DB systems) por projeto */
# Bancos de Dados: Sistemas de gerenciamento de dados (ex: Oracle Database)
variable "project_databases" {
      # Mapa com parâmetros para criar DB systems. Contém informações sensíveis
      # como admin_password — evite commitar senhas em texto claro no repositório. 
  type = map(object({
    availability_domain = string, # Zona de disponibilidade para alta disponibilidade
    compartment_id      = string, # Compartimento do banco
    shape               = string, # Tipo/tamanho da VM que hospeda o BD
    subnet_id           = string, # Sub-rede onde o BD será conectado
    database_edition    = string, # Versão/edição do Oracle Database
    db_name             = string, # Nome único do banco de dados
    admin_password      = string  # Senha do usuário administrador (SYS ou ADMIN)
  }))
  default = {}
}

