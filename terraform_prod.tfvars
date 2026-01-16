# ====================================================================
# ARQUIVO: terraform_prod.tfvars
# DESCRIÇÃO: Arquivo de valores das variáveis para o ambiente PRODUÇÃO
#            Contém os valores reais que serão usados ao criar a infraestrutura
#            ATENÇÃO: Não comitar dados sensíveis (senhas, chaves) em repositórios públicos!
# ====================================================================

# ---- CREDENCIAIS E AUTENTICAÇÃO OCI ----
# --- Autenticação / Configuração do provider OCI ---

region           = "sa-saopaulo-1"
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaaehlqeml7m3rbt7f66fknd6z4dqyijnrslo7j7luvaacdf22vf7rq"
user_ocid        = "ocid1.user.oc1..aaaaaaaatid5j2c4adsj3ifwyemhduip5ecz7onvo4egqo2gqhwq2o3jpeqa"
fingerprint      = "c3:a1:bd:38:7b:1e:10:58:6c:14:da:3d:70:a2:5a:4c"
private_key_path = "/Users/joubertgabriel/.oci/nova_api_key.pem"  # Usando a mesma chave API para ambos os ambientes


# ---- OCID DO COMPARTIMENTO DE REDE ----
# IMPORTANTE: Substitua pelo OCID real do compartimento "shared-network-prod"
# ---- COMPARTIMENTOS ----
# --- Compartimentos (compartments) ---
# Compartimentos são divisões lógicas dentro da conta OCI
# Servem para organizar recursos, isolar acesso e controlar custos
compartments = {
  # ATENÇÃO: Para o primeiro apply, deixe apenas o compartimento raiz "prod" abaixo.
  # Após rodar o terraform apply, copie o OCID real do compartimento "prod" criado
  # e atualize o campo parent_ocid dos filhos (shared-network-prod, projeto-a-prod).
  # Depois, reintroduza os filhos e rode o apply novamente.
  "prod" = {
    description = "Compartimento de produção"
    parent_ocid = "ocid1.tenancy.oc1..aaaaaaaaehlqeml7m3rbt7f66fknd6z4dqyijnrslo7j7luvaacdf22vf7rq"  # Pai é a tenancy
  }
}

# ---- CONFIGURAÇÃO DE REDE (VCN e Sub-redes) ----

# Faixa de endereços IP da Rede Virtual Cloud (VCN) principal
# 10.1.0.0/16 oferece 65.536 endereços IP disponíveis
# --- Rede (VCN e subnets) ---
  # vcn_cidr: CIDR principal da VCN
vcn_cidr = "10.1.0.0/16"

# Sub-redes dividem a VCN em redes menores
subnet_cidrs = {
    # Sub-rede pública: recursos acessíveis da internet (com NAT Gateway)
    # 10.1.1.0/24 oferece ~250 endereços IP
  public  = "10.1.1.0/24"

    # Sub-rede privada: recursos sem acesso direto da internet (apenas via bastion)
    # 10.1.2.0/24 oferece ~250 endereços IP
  private = "10.1.2.0/24"
}

# ---- POLÍTICAS DE ACESSO (IAM) ----
# Define quem (grupos/usuários) pode fazer o quê em cada compartimento
project_policies = {}


# ---- MÁQUINAS VIRTUAIS (Instâncias) ----
# Cada projeto terá uma ou mais máquinas virtuais
# --- Instâncias (exemplo para projeto A) ---
project_instances = {
  "projeto-a-instance" = {
    availability_domain = "VFEJ:SA-SAOPAULO-1-AD-1"
    compartment_id      = "ocid1.compartment.oc1..aaaaaaaa5i7sfaqrneykgkfbxkjaxkqgq7cdu6anpfzedk7f4g6l2vrwgl5a" # projeto-a-prod
    shape               = "VM.Standard.E2.1.Micro"
    subnet_id           = "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaazvn3qzsindn3qpdom5p63dpbxnryjjfbbyvp4cvmat4agtv6pm5q" # pub_subnet_shared
    image_id            = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaadzfu47ymkk4sbvr66mcblrgkey6r5bjy7oau7hodv2tdllxbrodq" # Oracle Linux 8
  }

  # Segunda VM de exemplo
  "vm-teste-prod" = {
    availability_domain = "VFEJ:SA-SAOPAULO-1-AD-1"
    compartment_id      = "ocid1.compartment.oc1..aaaaaaaa5i7sfaqrneykgkfbxkjaxkqgq7cdu6anpfzedk7f4g6l2vrwgl5a" # projeto-a-prod
    shape               = "VM.Standard.E2.1.Micro"
    subnet_id           = "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaazvn3qzsindn3qpdom5p63dpbxnryjjfbbyvp4cvmat4agtv6pm5q" # pub_subnet_shared
    image_id            = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaadzfu47ymkk4sbvr66mcblrgkey6r5bjy7oau7hodv2tdllxbrodq" # Oracle Linux 8
  }

  # Terceira VM de exemplo
  "vm-web-prod" = {
    availability_domain = "VFEJ:SA-SAOPAULO-1-AD-1"
    compartment_id      = "ocid1.compartment.oc1..aaaaaaaa5i7sfaqrneykgkfbxkjaxkqgq7cdu6anpfzedk7f4g6l2vrwgl5a" # projeto-a-prod
    shape               = "VM.Standard.E2.1.Micro"
    subnet_id           = "ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaazvn3qzsindn3qpdom5p63dpbxnryjjfbbyvp4cvmat4agtv6pm5q" # pub_subnet_shared
    image_id            = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaadzfu47ymkk4sbvr66mcblrgkey6r5bjy7oau7hodv2tdllxbrodq" # Oracle Linux 8
}

# ---- ARMAZENAMENTO EM OBJETO (Buckets) ----
# --- Buckets (Object Storage) por projeto ---
# Para guardar arquivos, logs, backups, etc
project_buckets = {
  "projeto-a" = {
    compartment_id = "ocid1.compartment.oc1..aaaaaaaa5i7sfaqrneykgkfbxkjaxkqgq7cdu6anpfzedk7f4g6l2vrwgl5a" # projeto-a-prod
    namespace      = "grmfmdmm0jtb" # namespace correto da tenancy OCI
  }
}

# ---- BANCOS DE DADOS ----
# Para aplicações que precisam armazenar dados estruturados (SQL)
# --- Bancos de Dados (exemplo) ---
project_databases = {}

# ---- SUBNETS DEDICADAS POR PROJETO (OPCIONAL) ----
# Declarar subnets dedicadas somente quando o projeto exigir isolamento
project_subnets = {}

# Flags de controle para criação opcional
enable_child_compartments = true
enable_project_subnets    = false
enable_service_gateway_routes = false
