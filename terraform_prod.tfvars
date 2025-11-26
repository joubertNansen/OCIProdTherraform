# ====================================================================
# ARQUIVO: terraform_nonprod.tfvars
# DESCRIÇÃO: Arquivo de valores das variáveis para o ambiente PRODUÇÃO
#            Contém os valores reais que serão usados ao criar a infraestrutura
#            ATENÇÃO: Não comitar dados sensíveis (senhas, chaves) em repositórios públicos!
# ====================================================================

# ---- CREDENCIAIS E AUTENTICAÇÃO OCI ----
# --- Autenticação / Configuração do provider OCI ---

region           = "sa-saopaulo-1"
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaaehlqeml7m3rbt7f66fknd6z4dqyijnrslo7j7luvaacdf22vf7rq"
user_ocid        = "ocid1.user.oc1..aaaaaaaatid5j2c4adsj3ifwyemhduip5ecz7onvo4egqo2gqhwq2o3jpeqa"
fingerprint      = "6d:08:5e:78:27:3b:e8:fc:de:8e:73:b3:93:f9:08:1c"
private_key_path = "C:\\Users\\nsn102225\\.oci\\oci_api_key"


# ---- COMPARTIMENTOS ----
# --- Compartimentos (compartments) ---
# Compartimentos são divisões lógicas dentro da conta OCI
# Servem para organizar recursos, isolar acesso e controlar custos
compartments = {
    # Compartimento raiz para ambiente produção
  "prod" = {
    description = "Compartimento de produção"
    parent_ocid = "ocid1.tenancy.oc1..aaaaaaaaehlqeml7m3rbt7f66fknd6z4dqyijnrslo7j7luvaacdf22vf7rq" # Pai é a tenancy
  },
    # Compartimento compartilhado de rede (recursos compartilhados entre projetos)
  "shared-network-prod" = {
    description = "Rede compartilhada produção"
    parent_ocid = "ocid1.compartment.oc1..prodCompID" # Pai é o compartimento "prod"
  },
    # Compartimento específico do Projeto A
  "projeto-a-prod" = {
    description = "Projeto A produção" 
    parent_ocid = "ocid1.compartment.oc1..prodCompID" # Pai é o compartimento "prod"
  }
}

# ---- CONFIGURAÇÃO DE REDE (VCN e Sub-redes) ----

# Faixa de endereços IP da Rede Virtual Cloud (VCN) principal
# 10.2.0.0/16 oferece 65.536 endereços IP disponíveis

# --- Rede (VCN e subnets) ---
  # vcn_cidr: CIDR principal da VCN
vcn_cidr = "10.1.0.0/16"

# Sub-redes dividem a VCN em redes menores
subnet_cidrs = {
    # Sub-rede pública: recursos acessíveis da internet (com NAT Gateway)
    # 10.2.1.0/24 oferece ~250 endereços IP
  public  = "10.1.1.0/24"

    # Sub-rede privada: recursos sem acesso direto da internet (apenas via bastion)
    # 10.2.2.0/24 oferece ~250 endereços IP
  private = "10.1.2.0/24"
}


# ---- POLÍTICAS DE ACESSO (IAM) ----
# Define quem (grupos/usuários) pode fazer o quê em cada compartimento
project_policies = {}

# ---- MÁQUINAS VIRTUAIS (Instâncias) ----
# Cada projeto terá uma ou mais máquinas virtuais
# --- Instâncias (exemplo para projeto A) ---
project_instances = {}

# ---- ARMAZENAMENTO EM OBJETO (Buckets) ----
# --- Buckets (Object Storage) por projeto ---
# Para guardar arquivos, logs, backups, etc
project_buckets = {}

# ---- BANCOS DE DADOS ----
# Para aplicações que precisam armazenar dados estruturados (SQL)
# --- Bancos de Dados (exemplo) ---
project_databases = {}

# ---- SUBNETS DEDICADAS POR PROJETO (OPCIONAL) ----
project_subnets = {}
