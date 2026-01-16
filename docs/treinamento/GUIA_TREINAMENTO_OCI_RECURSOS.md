# Guia Completo de Recursos OCI para Treinamento da Equipe

## Visão Geral dos Serviços OCI

### 1. Compute (Computação)
**OCI Compute** oferece instâncias virtuais (VMs) e bare metal para executar aplicações.

#### Principais Recursos:
- **Instâncias VM**: Máquinas virtuais com diferentes shapes (VM.Standard.E4.Flex, VM.Standard.A1.Flex)
- **Instâncias Bare Metal**: Servidores físicos dedicados
- **Dedicated VM Hosts**: Hosts dedicados para VMs
- **Capacity Reservations**: Reserva de capacidade para instâncias

#### Exemplo Terraform:
```hcl
resource "oci_core_instance" "web_server" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.E4.Flex"
  shape_config {
    ocpus         = 1
    memory_in_gbs = 16
  }
  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid
  }
  create_vnic_details {
    subnet_id                 = oci_core_subnet.web_subnet.id
    display_name              = "primaryvnic"
    assign_public_ip          = true
    assign_private_dns_record = true
  }
  display_name = "web-server"
}
```

### 2. Networking (Rede)
**OCI Networking** fornece conectividade segura e de alta performance.

#### Principais Recursos:
- **Virtual Cloud Networks (VCN)**: Redes virtuais isoladas
- **Subnets**: Sub-redes dentro das VCNs
- **Internet Gateways**: Acesso à internet
- **NAT Gateways**: Tradução de endereços para saída
- **Service Gateways**: Acesso aos serviços OCI
- **Dynamic Routing Gateways (DRG)**: Conectividade com redes on-premises
- **Load Balancers**: Distribuição de tráfego
- **Network Security Groups (NSG)**: Controle de segurança granular

#### Exemplo Terraform:
```hcl
resource "oci_core_virtual_network" "vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_id
  display_name   = "vcn-prod"
  dns_label      = "vcnprod"
}

resource "oci_core_subnet" "web_subnet" {
  cidr_block                 = "10.0.1.0/24"
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_virtual_network.vcn.id
  display_name               = "web-subnet"
  dns_label                  = "websubnet"
  security_list_ids          = [oci_core_security_list.web_security_list.id]
  route_table_id             = oci_core_route_table.web_route_table.id
  prohibit_public_ip_on_vnic = false
}
```

### 3. Storage (Armazenamento)
**OCI Storage** oferece soluções escaláveis e duráveis.

#### Principais Recursos:
- **Object Storage**: Armazenamento de objetos com alta durabilidade
- **Block Storage**: Volumes de bloco para instâncias
- **File Storage**: Sistema de arquivos compartilhado
- **Archive Storage**: Armazenamento de longo prazo de baixo custo

#### Exemplo Terraform:
```hcl
resource "oci_objectstorage_bucket" "bucket" {
  compartment_id = var.compartment_id
  name           = "my-bucket"
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  storage_tier   = "Standard"
}

resource "oci_core_volume" "block_volume" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "block-volume"
  size_in_gbs         = 50
}
```

### 4. Database (Banco de Dados)
**OCI Database** fornece serviços de banco de dados gerenciados.

#### Principais Recursos:
- **Autonomous Database**: Banco de dados auto-gerenciado
- **DB Systems**: Sistemas de banco de dados tradicionais
- **MySQL Database Service**: Serviço MySQL gerenciado
- **NoSQL Database**: Banco de dados NoSQL
- **Exadata Cloud**: Infraestrutura de alto desempenho

#### Exemplo Terraform:
```hcl
resource "oci_database_autonomous_database" "autonomous_database" {
  compartment_id           = var.compartment_id
  cpu_core_count          = 1
  data_storage_size_in_tbs = 1
  db_name                 = "myatp"
  admin_password          = var.autonomous_database_admin_password
  display_name            = "My Autonomous Database"
  db_workload             = "OLTP"
  is_free_tier            = false
}
```

### 5. Identity & Access Management (IAM)
**OCI IAM** gerencia usuários, grupos e permissões.

#### Principais Recursos:
- **Compartments**: Contêineres lógicos para recursos
- **Users**: Usuários do OCI
- **Groups**: Grupos de usuários
- **Policies**: Regras de acesso baseadas em recursos
- **Dynamic Groups**: Grupos baseados em regras

#### Exemplo Terraform:
```hcl
resource "oci_identity_compartment" "compartment" {
  compartment_id = var.tenancy_ocid
  description    = "Compartment for production resources"
  name           = "prod-compartment"
}

resource "oci_identity_policy" "policy" {
  compartment_id = var.tenancy_ocid
  description    = "Policy for production compartment"
  name           = "prod-policy"
  statements = [
    "Allow group Administrators to manage all-resources in compartment prod-compartment"
  ]
}
```

### 6. Load Balancing
**OCI Load Balancing** distribui tráfego entre instâncias.

#### Principais Recursos:
- **Load Balancers**: Balanceamento de carga L7
- **Network Load Balancers**: Balanceamento de carga L4

#### Exemplo Terraform:
```hcl
resource "oci_load_balancer_load_balancer" "load_balancer" {
  compartment_id             = var.compartment_id
  display_name               = "load-balancer"
  shape                      = "100Mbps"
  subnet_ids                 = [oci_core_subnet.lb_subnet.id]
  is_private                 = false
}

resource "oci_load_balancer_backend_set" "backend_set" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  name             = "backend-set"
  policy           = "ROUND_ROBIN"
  health_checker {
    protocol = "HTTP"
    port     = 80
  }
}
```

### 7. Security (Segurança)
**OCI Security** protege recursos e dados.

#### Principais Recursos:
- **Web Application Firewall (WAF)**: Proteção contra ataques web
- **Cloud Guard**: Monitoramento de segurança
- **Security Zones**: Zonas de segurança automatizadas
- **Key Management**: Gerenciamento de chaves
- **Certificates**: Gerenciamento de certificados

### 8. Analytics & AI
**OCI Analytics & AI** oferece serviços de análise e inteligência artificial.

#### Principais Recursos:
- **Analytics Cloud**: Plataforma de análise de dados
- **Data Science**: Ambiente para ciência de dados
- **AI Services**: Serviços de IA pré-treinados
- **Data Flow**: Processamento de dados em lote

### 9. Integration (Integração)
**OCI Integration** conecta aplicações e sistemas.

#### Principais Recursos:
- **API Gateway**: Gerenciamento de APIs
- **Events**: Sistema de eventos
- **Notifications**: Serviço de notificações
- **Streams**: Streaming de dados

### 10. Developer Services
**OCI Developer Services** acelera o desenvolvimento.

#### Principais Recursos:
- **Container Engine for Kubernetes (OKE)**: Kubernetes gerenciado
- **Functions**: Serverless functions
- **Resource Manager**: Gerenciamento de infraestrutura como código
- **DevOps**: Pipelines CI/CD

#### Exemplo Terraform para OKE:
```hcl
resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = var.compartment_id
  kubernetes_version = "v1.24.1"
  name               = "oke-cluster"
  vcn_id             = oci_core_virtual_network.vcn.id
  options {
    service_lb_subnet_ids = [oci_core_subnet.service_lb_subnet.id]
  }
}
```

## Operações CRUD com Terraform

### Create (Criar)
```bash
terraform plan -out=tfplan
terraform apply tfplan
```

### Read (Ler)
```bash
terraform show
terraform output
```

### Update (Atualizar)
```bash
terraform plan -out=tfplan
terraform apply tfplan
```

### Delete (Deletar)
```bash
terraform plan -destroy -out=tfplan
terraform apply tfplan
```

## Melhores Práticas

1. **Organização**: Use compartments para organizar recursos
2. **Segurança**: Implemente políticas de menor privilégio
3. **Monitoramento**: Use Cloud Guard e Logging
4. **Backup**: Configure backups automáticos para bancos de dados
5. **Redundância**: Use múltiplas availability domains
6. **Custos**: Monitore uso e configure budgets

## Laboratório Prático

Para o treinamento da equipe, sugerimos os seguintes exercícios:

1. **Exercício 1**: Criar VCN com subnets
2. **Exercício 2**: Provisionar instância VM
3. **Exercício 3**: Configurar Load Balancer
4. **Exercício 4**: Criar Autonomous Database
5. **Exercício 5**: Implementar políticas IAM
6. **Exercício 6**: Configurar Object Storage
7. **Exercício 7**: Deploy de aplicação containerizada no OKE

Cada exercício deve incluir:
- Objetivo
- Pré-requisitos
- Passos detalhados
- Código Terraform
- Validação
- Limpeza de recursos