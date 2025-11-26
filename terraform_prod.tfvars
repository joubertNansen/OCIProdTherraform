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
fingerprint      = "bb:66:46:a2:e6:db:c4:26:d8:80:13:dc:12:4c:61:cf"
private_key_path = "C:\\Users\\nsn102225\\.oci\\oci_api_key"


# ---- COMPARTIMENTOS ----
# --- Compartimentos (compartments) ---
# Compartimentos são divisões lógicas dentro da conta OCI
# Servem para organizar recursos, isolar acesso e controlar custos
compartments = {
    # Compartimento raiz para ambiente produção
  "prod" = {
    description = "Compartimento de produção"
    parent_ocid = "ocid1.tenancy.oc1..prodTenancyID" # Pai é a tenancy
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
project_policies = {
   # Política para o Projeto A
  "projeto-a-prod" = {
      # Compartimento onde a política será aplicada
    compartment_id = "ocid1.compartment.oc1..projetoAProdID"

    # Regras de permissão
    statements = [
        # Permite que o grupo "Devs" gerencie TODOS os recursos no compartimento do projeto
      "Allow group Devs to manage all-resources in compartment projeto-a-prod",

        # Permite que o grupo "Devs" use recursos de rede no compartimento compartilhado
        # (precisa de acesso à rede para criar máquinas virtuais, bancos de dados, etc)
      "Allow group Devs to use virtual-network-family in compartment shared-network-prod"
    ]
  }
}

# ---- MÁQUINAS VIRTUAIS (Instâncias) ----
# Cada projeto terá uma ou mais máquinas virtuais
# --- Instâncias (exemplo para projeto A) ---
project_instances = {
    # Máquina virtual para o Projeto A
  "projeto-a-prod" = {
      # Zona de disponibilidade (data center) - use diferentes para redundância
    availability_domain = "SA-SAOPAULO-1-AD-1"
      # Compartimento onde a VM será criada
    compartment_id      = "ocid1.compartment.oc1..projetoAProdID"
      # Tamanho/tipo da máquina
      # VM.Standard.E4.Flex = processador flexível, vCPUs e memória configuráveis
    shape               = "VM.Standard.E4.Flex"
      # Sub-rede onde a VM será conectada (neste caso, pública para acesso web)
    subnet_id           = "ocid1.subnet.oc1..prodPublicSubnetID"
      # Imagem do sistema operacional a instalar (ex: Ubuntu, CentOS, Windows, etc)
    image_id            = "ocid1.image.oc1.sa-saopaulo-1.prodImageID"
  }
}

# ---- ARMAZENAMENTO EM OBJETO (Buckets) ----
# --- Buckets (Object Storage) por projeto ---
# Para guardar arquivos, logs, backups, etc
project_buckets = {
    # Bucket para o Projeto A
  "projeto-a-prod" = {
      # Compartimento do bucket
    compartment_id = "ocid1.compartment.oc1..projetoAProdID"
      # Namespace (identifica globalmente o bucket na OCI)
      # Geralmente é o namespace da tenancy
    namespace      = "prod_namespace"
  }
}

# ---- BANCOS DE DADOS ----
# Para aplicações que precisam armazenar dados estruturados (SQL)
# --- Bancos de Dados (exemplo) ---
project_databases = {
    # Banco de dados para o Projeto A
  "projeto-a-prod" = {
      # Zona de disponibilidade - usar privada/interna é mais seguro
    availability_domain = "SA-SAOPAULO-1-AD-1"
      # Compartimento do banco
    compartment_id      = "ocid1.compartment.oc1..projetoAProdID"
      # Tamanho da máquina hospedando o BD
      # VM.Standard2.1 = máquina pequena com 1 OCPU (suficiente para non-prod)
    shape               = "VM.Standard2.1"
      # Sub-rede PRIVADA (IMPORTANTE: bancos NÃO devem ser públicos)
      # Acesso apenas através de bastion host ou via rede interna
    subnet_id           = "ocid1.subnet.oc1..prodPrivateSubnetID"
      # Edição do Oracle Database
      # STANDARD_EDITION = versão básica (suficiente para desenvolvimento)
      # ENTERPRISE_EDITION = versão completa (features avançadas)
    database_edition    = "ENTERPRISE_EDITION"
      # Nome único do banco de dados (SID do Oracle)
    db_name             = "prod_db"
      # Senha do usuário administrador (SYS/ADMIN)
      # ⚠️ SEGURANÇA: Armazenar em vault/secrets manager, não em código aberto!
      # Usar senhas fortes: maiúsculas, minúsculas, números, símbolos
    admin_password      = "ProdPassword123!"
  }
}

# ---- SUBNETS DEDICADAS POR PROJETO (EXEMPLO) ----
project_subnets = {
  "projeto-a-prod" = {
    cidr_block  = "10.1.10.0/24"
    public      = true
    compartment = "projeto-a-prod"
  }
  "projeto-b-prod" = {
    cidr_block  = "10.1.11.0/24"
    public      = false
    compartment = "projeto-b-prod"
  }
}
