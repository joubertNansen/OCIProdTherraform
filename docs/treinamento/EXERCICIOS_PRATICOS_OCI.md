# Exercícios Práticos OCI - Treinamento da Equipe

## Configuração Inicial

### Pré-requisitos
1. Conta OCI ativa
2. OCI CLI instalado e configurado
3. Terraform v1.0+ instalado
4. Chaves API configuradas
5. Acesso ao repositório GitHub do projeto

### Configuração do Ambiente
```bash
# Clonar repositório
git clone https://github.com/joubertgabriel/oci-terraform-infrastructure.git
cd oci-terraform-infrastructure

# Configurar variáveis de ambiente
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..aaaa..."
export TF_VAR_user_ocid="ocid1.user.oc1..aaaa..."
export TF_VAR_fingerprint="aa:bb:cc:..."
export TF_VAR_private_key_path="~/.oci/oci_api_key.pem"
export TF_VAR_region="sa-saopaulo-1"
```

---

## Exercício 1: Criando Virtual Cloud Network (VCN)

### Objetivo
Criar uma VCN com subnets públicas e privadas, incluindo gateways necessários.

### Arquivos Necessários
- `vcn.tf`
- `variables.tf`
- `outputs.tf`

### Código Terraform
```hcl
# vcn.tf
resource "oci_core_virtual_network" "vcn" {
  cidr_block     = var.vcn_cidr_block
  compartment_id = var.compartment_id
  display_name   = var.vcn_display_name
  dns_label      = var.vcn_dns_label
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "Internet Gateway"
}

resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "NAT Gateway"
}

resource "oci_core_route_table" "public_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "Public Route Table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

resource "oci_core_route_table" "private_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "Private Route Table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
  }
}

resource "oci_core_security_list" "public_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "Public Security List"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      destination_port_range {
        max = 22
        min = 22
      }
    }
  }
}

resource "oci_core_subnet" "public_subnet" {
  cidr_block                 = var.public_subnet_cidr
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_virtual_network.vcn.id
  display_name               = "Public Subnet"
  dns_label                  = "public"
  security_list_ids          = [oci_core_security_list.public_security_list.id]
  route_table_id             = oci_core_route_table.public_route_table.id
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "private_subnet" {
  cidr_block                 = var.private_subnet_cidr
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_virtual_network.vcn.id
  display_name               = "Private Subnet"
  dns_label                  = "private"
  security_list_ids          = [oci_core_security_list.public_security_list.id]
  route_table_id             = oci_core_route_table.private_route_table.id
  prohibit_public_ip_on_vnic = true
}
```

### Validação
```bash
# Verificar VCN criada
oci network vcn list --compartment-id $TF_VAR_compartment_id

# Verificar subnets
oci network subnet list --compartment-id $TF_VAR_compartment_id --vcn-id <vcn_ocid>

# Testar conectividade
terraform output
```

---

## Exercício 2: Provisionando Instância Compute

### Objetivo
Criar uma instância VM Ubuntu com acesso SSH.

### Código Terraform
```hcl
# instances.tf
data "oci_core_images" "ubuntu_images" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.E4.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

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
    source_id   = data.oci_core_images.ubuntu_images.images[0].image_id
  }
  create_vnic_details {
    subnet_id                 = oci_core_subnet.public_subnet.id
    display_name              = "primaryvnic"
    assign_public_ip          = true
    assign_private_dns_record = true
  }
  display_name = "web-server"
  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data           = base64encode(file("cloud-init.sh"))
  }
}
```

### Arquivo cloud-init.sh
```bash
#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx
echo "<h1>Web Server OCI</h1>" > /var/www/html/index.html
```

### Validação
```bash
# Verificar instância
oci compute instance list --compartment-id $TF_VAR_compartment_id

# Testar acesso SSH
ssh -i ~/.ssh/id_rsa ubuntu@<public_ip>

# Verificar nginx
curl http://<public_ip>
```

---

## Exercício 3: Configurando Load Balancer

### Objetivo
Criar Load Balancer para distribuir tráfego entre múltiplas instâncias.

### Código Terraform
```hcl
# load_balancer.tf
resource "oci_load_balancer_load_balancer" "load_balancer" {
  compartment_id             = var.compartment_id
  display_name               = "web-lb"
  shape                      = "100Mbps"
  subnet_ids                 = [oci_core_subnet.public_subnet.id]
  is_private                 = false
}

resource "oci_load_balancer_backend_set" "backend_set" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  name             = "web-backend-set"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol = "HTTP"
    port     = 80
    url_path = "/"
  }
}

resource "oci_load_balancer_backend" "backend" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  backendset_name  = oci_load_balancer_backend_set.backend_set.name
  ip_address       = oci_core_instance.web_server.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_listener" "listener" {
  load_balancer_id         = oci_load_balancer_load_balancer.load_balancer.id
  name                     = "http-listener"
  default_backend_set_name = oci_load_balancer_backend_set.backend_set.name
  port                     = 80
  protocol                 = "HTTP"
}
```

### Validação
```bash
# Verificar Load Balancer
oci lb load-balancer list --compartment-id $TF_VAR_compartment_id

# Testar Load Balancer
curl http://<lb_public_ip>
```

---

## Exercício 4: Criando Autonomous Database

### Objetivo
Provisionar um Autonomous Database para aplicação.

### Código Terraform
```hcl
# database.tf
resource "oci_database_autonomous_database" "autonomous_database" {
  compartment_id           = var.compartment_id
  cpu_core_count          = 1
  data_storage_size_in_tbs = 1
  db_name                 = "myatp"
  admin_password          = var.db_admin_password
  display_name            = "My Autonomous Database"
  db_workload             = "OLTP"
  is_free_tier            = false
  license_model           = "LICENSE_INCLUDED"
}
```

### Validação
```bash
# Verificar Autonomous Database
oci db autonomous-database list --compartment-id $TF_VAR_compartment_id

# Conectar via SQL Developer ou sqlplus
# Connection String estará disponível nos outputs do Terraform
```

---

## Exercício 5: Implementando Políticas IAM

### Objetivo
Configurar controle de acesso usando compartments e políticas.

### Código Terraform
```hcl
# compartments.tf
resource "oci_identity_compartment" "prod_compartment" {
  compartment_id = var.tenancy_ocid
  description    = "Compartment for production resources"
  name           = "prod"
}

resource "oci_identity_compartment" "dev_compartment" {
  compartment_id = var.tenancy_ocid
  description    = "Compartment for development resources"
  name           = "dev"
}

# iam_policies.tf
resource "oci_identity_group" "developers" {
  compartment_id = var.tenancy_ocid
  description    = "Group for developers"
  name           = "developers"
}

resource "oci_identity_policy" "dev_policy" {
  compartment_id = oci_identity_compartment.dev_compartment.id
  description    = "Policy for development compartment"
  name           = "dev-policy"
  statements = [
    "Allow group developers to manage instances in compartment dev",
    "Allow group developers to manage vnics in compartment dev",
    "Allow group developers to manage volumes in compartment dev"
  ]
}

resource "oci_identity_policy" "prod_policy" {
  compartment_id = oci_identity_compartment.prod_compartment.id
  description    = "Policy for production compartment"
  name           = "prod-policy"
  statements = [
    "Allow group developers to read instances in compartment prod",
    "Allow group developers to read vnics in compartment prod"
  ]
}
```

### Validação
```bash
# Verificar compartments
oci iam compartment list

# Verificar políticas
oci iam policy list --compartment-id $TF_VAR_tenancy_ocid
```

---

## Exercício 6: Configurando Object Storage

### Objetivo
Criar bucket e configurar acesso para armazenamento de arquivos.

### Código Terraform
```hcl
# storage.tf
resource "oci_objectstorage_bucket" "bucket" {
  compartment_id = var.compartment_id
  name           = "my-app-bucket"
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  storage_tier   = "Standard"
  versioning     = "Enabled"
}

# Políticas para acesso ao bucket
resource "oci_identity_policy" "storage_policy" {
  compartment_id = var.tenancy_ocid
  description    = "Policy for object storage access"
  name           = "storage-policy"
  statements = [
    "Allow group developers to manage objects in compartment ${var.compartment_name} where target.bucket.name='my-app-bucket'"
  ]
}
```

### Validação
```bash
# Verificar bucket
oci os bucket list --compartment-id $TF_VAR_compartment_id

# Upload de arquivo de teste
echo "Test file" > test.txt
oci os object put --bucket-name my-app-bucket --file test.txt

# Listar objetos
oci os object list --bucket-name my-app-bucket
```

---

## Exercício 7: Deploy no Kubernetes (OKE)

### Objetivo
Criar cluster OKE e fazer deploy de aplicação.

### Código Terraform
```hcl
# oke.tf
resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = var.compartment_id
  kubernetes_version = "v1.24.1"
  name               = "my-oke-cluster"
  vcn_id             = oci_core_virtual_network.vcn.id

  options {
    service_lb_subnet_ids = [oci_core_subnet.public_subnet.id]
  }
}

resource "oci_containerengine_node_pool" "node_pool" {
  cluster_id     = oci_containerengine_cluster.oke_cluster.id
  compartment_id = var.compartment_id
  name           = "node-pool"
  node_shape     = "VM.Standard.E4.Flex"

  node_config_details {
    size = 3

    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.private_subnet.id
    }
  }

  node_shape_config {
    ocpus         = 1
    memory_in_gbs = 16
  }

  initial_node_labels {
    key   = "environment"
    value = "training"
  }
}
```

### Arquivo deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-app
        image: nginx:latest
        ports:
        - containerPort: 80
```

### Validação
```bash
# Configurar kubectl
oci ce cluster create-kubeconfig --cluster-id <cluster_ocid> --file ~/.kube/config

# Verificar nodes
kubectl get nodes

# Aplicar deployment
kubectl apply -f deployment.yaml

# Verificar pods
kubectl get pods

# Expor serviço
kubectl expose deployment web-app --type=LoadBalancer --port=80
```

---

## Limpeza de Recursos

### Comando para destruir todos os recursos
```bash
terraform destroy -auto-approve
```

### Verificação final
```bash
# Verificar se todos os recursos foram removidos
oci compute instance list --compartment-id $TF_VAR_compartment_id
oci network vcn list --compartment-id $TF_VAR_compartment_id
oci db autonomous-database list --compartment-id $TF_VAR_compartment_id
```

## Dicas para o Treinamento

1. **Execução por etapas**: Cada exercício deve ser executado sequencialmente
2. **Documentação**: Incentivar a equipe a documentar cada passo
3. **Troubleshooting**: Ensinar uso de `terraform plan` e `terraform show`
4. **Custos**: Mostrar como monitorar custos no OCI Console
5. **Segurança**: Reforçar conceitos de menor privilégio
6. **Backup**: Demonstrar importância de state files e backups

## Próximos Passos

Após completar estes exercícios, a equipe estará preparada para:
- Gerenciar infraestrutura OCI com Terraform
- Implementar melhores práticas de segurança
- Monitorar e otimizar custos
- Automatizar deployments
- Solucionar problemas comuns