# ====================================================================
# ARQUIVO: variables.tf
# DESCRIÇÃO: Define todas as variáveis que são usadas na infraestrutura
#            Estas são como "parâmetros" que podem ser alterados sem
#            modificar o código, facilitando reutilização em diferentes ambientes
# ====================================================================

# ---- VARIÁVEIS DE AUTENTICAÇÃO (Obrigatórias) ----

/* Credenciais e região (usadas pelo provider OCI) */
variable "tenancy_ocid" { type = string } # Identificador único do inquilino (conta) na Oracle Cloud
variable "user_ocid" { type = string }    # Identificador do usuário que tem permissão para criar recursos
variable "fingerprint" { type = string }  # Impressão digital da chave pública usada na autenticação API
variable "private_key_path" { type = string }
variable "region" { type = string } # Região do OCI onde os recursos serão criados (ex: "sa-saopaulo-1")


# ---- VARIÁVEIS DE REDE ----

# Compartimentos: Divisões lógicas dentro da conta OCI para organizar recursos
# Cada compartimento tem seu próprio escopo de segurança e acesso
variable "compartments" {
  # Mapa onde a chave é o nome lógico do compartimento e o valor é um objeto
  # com descrição e parent_ocid (OCID do compartimento pai ou tenancy).
  type = map(object({
    description = string # Descrição do compartimento
    parent_ocid = string # OCID do compartimento pai/raiz
  }))
  default = {}
}

/* Rede (VCN e subnets) */
# CIDR (Classless Inter-Domain Routing) da Rede Virtual (VCN)
# Define a faixa de endereços IP disponíveis (10.0.0.0/16 = 65.536 IPs)
variable "vcn_cidr" {
  type    = string
  default = "10.0.0.0/16"
}


# Sub-redes (subnets): Divisões da VCN em faixas IP menores
# public: para recursos expostos à internet
# private: para recursos sem acesso direto à internet
variable "subnet_cidrs" {
  type = map(string)
  default = {
    public  = "10.0.1.0/24" # 254 IPs disponíveis
    private = "10.0.2.0/24" # 254 IPs disponíveis
  }
}

# ---- SUBNETS DEDICADAS POR PROJETO ----
# Permite declarar subnets dedicadas para projetos específicos quando necessário
variable "project_subnets" {
  type = map(object({
    cidr_block  = string
    public      = bool
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
    # Cada valor pode conter 'compartment_id' (OCID) ou 'compartment' (nome lógico) e 'statements' (lista de strings)
    type = map(any)
  default = {}
}

# ---- VARIÁVEIS DE MÁQUINAS VIRTUAIS ----

/* Instâncias (VMs) por projeto */
# Instâncias: Máquinas virtuais que rodam na Oracle Cloud
# Este mapa é flexível: cada entrada pode fornecer OCIDs diretos (compartment_id, subnet_id)
# ou referências lógicas (compartment = nome_em_var.compartments, subnet = chave_em_var.project_subnets).
variable "project_instances" {
  type    = map(any)
  default = {}
}

# ---- VARIÁVEIS DE ARMAZENAMENTO ----

/* Buckets (Object Storage) por projeto */
# Buckets: Armazenamento em nuvem para arquivos (similar ao S3 da AWS)
variable "project_buckets" {
  # Cada entrada pode usar `compartment_id` (OCID) ou `compartment` (nome lógico em var.compartments)
  # Ex: project_buckets = { "projeto-x" = { compartment = "projeto-x-nonprod", namespace = "myns" } }
  type    = map(any)
  default = {}
}

# ---- VARIÁVEIS DE BANCO DE DADOS ----

/* Bancos de dados (DB systems) por projeto */
# Bancos de Dados: Sistemas de gerenciamento de dados (ex: Oracle Database)
variable "project_databases" {
  # Cada entrada pode prover OCIDs diretos ou referências lógicas
  # Ex:
  # project_databases = {
  #   "proj-db" = {
  #     availability_domain = "AD-1"
  #     compartment = "projeto-x-nonprod"    # ou compartment_id = "ocid1.compartment..."
  #     subnet = "projeto-x-nonprod-subnet"  # ou subnet_id = "ocid1.subnet..."
  #     shape = "VM.Standard2.1"
  #     database_edition = "STANDARD_EDITION"
  #     db_name = "projxdb"
  #     admin_password = "..."  # preferencialmente via vault / var de ambiente
  #   }
  # }
  type    = map(any)
  default = {}
}

# ---- FLAGS DE FUNCIONALIDADE PARA CRIAÇÕES OPCIONAIS ----
/*
  Essas flags permitem ativar blocos opcionais que em alguns ambientes
  exigem permissões ou valores adicionais. Padrão = false (desativado).
*/
variable "enable_child_compartments" {
  type    = bool
  default = false
}

variable "enable_project_subnets" {
  type    = bool
  default = false
}

variable "enable_service_gateway_routes" {
  type    = bool
  default = false
}

variable "service_gateway_destination" {
  description = "Destino usado na rota do Service Gateway (ex: service cidr ou string válida). Se vazio, não será criada a rota."
  type        = string
  default     = ""
}

variable "service_gateway_destination_type" {
  description = "Tipo do destino para a rota do Service Gateway (ex: SERVICE_CIDR_BLOCK ou CIDR_BLOCK)."
  type        = string
  default     = "SERVICE_CIDR_BLOCK"
}

# Ambiente atual (usado para selecionar chaves em maps e nomes legíveis)
# Exemplo: "prod" ou "nonprod". Permite compartilhar o mesmo código entre
# ambientes sem index errors quando um mapa só contém a chave do ambiente alvo.
variable "environment" {
  type    = string
  default = "prod"
}
