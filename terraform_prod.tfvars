

# --- Autenticação / Configuração do provider OCI ---
# region: região OCI onde os recursos serão criados (ex.: sa-saopaulo-1)
region           = "sa-saopaulo-1"
# tenancy_ocid, user_ocid e fingerprint são OCIDs/fingerprints fornecidos pela OCI
tenancy_ocid     = "ocid1.tenancy.oc1..prodTenancyID"
user_ocid        = "ocid1.user.oc1..prodUserID"
fingerprint      = "aa:bb:cc:dd:ee:ff:gg:hh:ii:jj:kk:ll:mm:nn:oo:pp"
# private_key_path: caminho para a chave privada local usada para autenticar
private_key_path = "~/.oci/prod_api_key.pem"


# --- Compartimentos (compartments) ---
# Definem as divisões lógicas (ex.: prod, shared-network-prod, projetos)
compartments = {
  "prod" = {
    description = "Compartimento de produção"
    parent_ocid = "ocid1.tenancy.oc1..prodTenancyID"
  },
  "shared-network-prod" = {
    description = "Rede compartilhada produção"
    parent_ocid = "ocid1.compartment.oc1..prodCompID"
  },
  "projeto-a-prod" = {
    description = "Projeto A produção"
    parent_ocid = "ocid1.compartment.oc1..prodCompID"
  }
}


# --- Rede (VCN e subnets) ---
# vcn_cidr: CIDR principal da VCN
vcn_cidr = "10.1.0.0/16"
subnet_cidrs = {
  public  = "10.1.1.0/24"
  private = "10.1.2.0/24"
}


# --- Políticas IAM (exemplos) ---
project_policies = {
  "projeto-a-prod" = {
    compartment_id = "ocid1.compartment.oc1..projetoAProdID"
    statements = [
      "Allow group Devs to manage all-resources in compartment projeto-a-prod",
      "Allow group Devs to use virtual-network-family in compartment shared-network-prod"
    ]
  }
}


# --- Instâncias (exemplo para projeto A) ---
project_instances = {
  "projeto-a-prod" = {
    availability_domain = "SA-SAOPAULO-1-AD-1"
    compartment_id      = "ocid1.compartment.oc1..projetoAProdID"
    shape               = "VM.Standard.E4.Flex"
    subnet_id           = "ocid1.subnet.oc1..prodPublicSubnetID"
    image_id            = "ocid1.image.oc1.sa-saopaulo-1.prodImageID"
  }
}


# --- Buckets (Object Storage) por projeto ---
project_buckets = {
  "projeto-a-prod" = {
    compartment_id = "ocid1.compartment.oc1..projetoAProdID"
    namespace      = "prod_namespace"
  }
}


# --- Bancos de Dados (exemplo) ---
project_databases = {
  "projeto-a-prod" = {
    availability_domain = "SA-SAOPAULO-1-AD-1"
    compartment_id      = "ocid1.compartment.oc1..projetoAProdID"
    shape               = "VM.Standard2.1"
    subnet_id           = "ocid1.subnet.oc1..prodPrivateSubnetID"
    database_edition    = "ENTERPRISE_EDITION"
    db_name             = "prod_db"
    admin_password      = "ProdPassword123!"
  }
}
