# Referência Rápida - Comandos OCI Essenciais

## OCI CLI - Comandos Principais

### Autenticação e Configuração
```bash
# Verificar configuração
oci setup config

# Testar autenticação
oci iam user get --user-id $OCI_USER_ID

# Listar regiões disponíveis
oci iam region list

# Verificar tenancy
oci iam tenancy get
```

### Compute (Instâncias)
```bash
# Listar instâncias
oci compute instance list --compartment-id $COMPARTMENT_ID

# Detalhes de uma instância
oci compute instance get --instance-id $INSTANCE_ID

# Iniciar instância
oci compute instance action --action START --instance-id $INSTANCE_ID

# Parar instância
oci compute instance action --action STOP --instance-id $INSTANCE_ID

# Reiniciar instância
oci compute instance action --action REBOOT --instance-id $INSTANCE_ID

# Listar shapes disponíveis
oci compute shape list --compartment-id $COMPARTMENT_ID

# Listar imagens
oci compute image list --compartment-id $COMPARTMENT_ID --operating-system "Canonical Ubuntu"
```

### Networking (Rede)
```bash
# Listar VCNs
oci network vcn list --compartment-id $COMPARTMENT_ID

# Detalhes da VCN
oci network vcn get --vcn-id $VCN_ID

# Listar subnets
oci network subnet list --compartment-id $COMPARTMENT_ID --vcn-id $VCN_ID

# Listar security lists
oci network security-list list --compartment-id $COMPARTMENT_ID --vcn-id $VCN_ID

# Verificar VNICs
oci network vnic list --compartment-id $COMPARTMENT_ID
```

### Storage (Armazenamento)
```bash
# Listar buckets
oci os bucket list --compartment-id $COMPARTMENT_ID

# Criar bucket
oci os bucket create --name my-bucket --compartment-id $COMPARTMENT_ID

# Upload de arquivo
oci os object put --bucket-name my-bucket --file arquivo.txt --name arquivo.txt

# Download de arquivo
oci os object get --bucket-name my-bucket --name arquivo.txt --file download.txt

# Listar objetos no bucket
oci os object list --bucket-name my-bucket

# Deletar objeto
oci os object delete --bucket-name my-bucket --name arquivo.txt
```

### Database (Banco de Dados)
```bash
# Listar Autonomous Databases
oci db autonomous-database list --compartment-id $COMPARTMENT_ID

# Detalhes do Autonomous Database
oci db autonomous-database get --autonomous-database-id $ADB_ID

# Iniciar Autonomous Database
oci db autonomous-database start --autonomous-database-id $ADB_ID

# Parar Autonomous Database
oci db autonomous-database stop --autonomous-database-id $ADB_ID

# Listar DB Systems
oci db system list --compartment-id $COMPARTMENT_ID
```

### Identity & Access Management (IAM)
```bash
# Listar compartments
oci iam compartment list

# Detalhes do compartment
oci iam compartment get --compartment-id $COMPARTMENT_ID

# Listar usuários
oci iam user list

# Listar grupos
oci iam group list

# Listar políticas
oci iam policy list --compartment-id $TENANCY_ID

# Listar dynamic groups
oci iam dynamic-group list
```

### Load Balancer
```bash
# Listar load balancers
oci lb load-balancer list --compartment-id $COMPARTMENT_ID

# Detalhes do load balancer
oci lb load-balancer get --load-balancer-id $LB_ID

# Listar backend sets
oci lb backend-set list --load-balancer-id $LB_ID

# Listar backends
oci lb backend list --load-balancer-id $LB_ID --backend-set-name $BACKEND_SET_NAME
```

## Terraform - Comandos Essenciais

### Inicialização e Planejamento
```bash
# Inicializar Terraform
terraform init

# Validar configuração
terraform validate

# Criar plano de execução
terraform plan

# Salvar plano em arquivo
terraform plan -out=tfplan

# Mostrar plano salvo
terraform show tfplan
```

### Aplicação e Gerenciamento
```bash
# Aplicar mudanças
terraform apply

# Aplicar plano salvo
terraform apply tfplan

# Aplicar sem confirmação
terraform apply -auto-approve

# Mostrar estado atual
terraform show

# Listar recursos gerenciados
terraform state list

# Mostrar detalhes de um recurso
terraform state show oci_core_instance.web_server
```

### Destruição e Limpeza
```bash
# Plano de destruição
terraform plan -destroy

# Destruir recursos
terraform destroy

# Destruir sem confirmação
terraform destroy -auto-approve

# Remover recursos específicos do state
terraform state rm oci_core_instance.web_server
```

### Debugging e Troubleshooting
```bash
# Verificar versão do provider
terraform providers

# Mostrar dependências
terraform graph

# Debug mode
TF_LOG=DEBUG terraform apply

# Refresh state
terraform refresh

# Importar recurso existente
terraform import oci_core_instance.existing_instance ocid1.instance.oc1...
```

## Monitoramento e Observabilidade

### Logging
```bash
# Listar logs
oci logging log list --compartment-id $COMPARTMENT_ID

# Ver logs de uma instância
oci compute instance-console-history capture --instance-id $INSTANCE_ID
```

### Metrics
```bash
# Listar métricas disponíveis
oci monitoring metric-data list --compartment-id $COMPARTMENT_ID --namespace oci_computeagent
```

### Budgets e Custos
```bash
# Verificar budgets
oci budgeting budget list --compartment-id $TENANCY_ID

# Ver uso atual
oci usage-api usage-summary list --compartment-id $COMPARTMENT_ID
```

## Scripts Úteis

### Script de Health Check
```bash
#!/bin/bash
echo "=== OCI Health Check ==="

# Verificar autenticação
echo "1. Verificando autenticação..."
oci iam user get --user-id $OCI_USER_ID > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Autenticação OK"
else
    echo "✗ Problema de autenticação"
fi

# Verificar instâncias
echo "2. Verificando instâncias..."
INSTANCE_COUNT=$(oci compute instance list --compartment-id $COMPARTMENT_ID --query 'length(data)' --raw-output)
echo "✓ $INSTANCE_COUNT instâncias encontradas"

# Verificar VCNs
echo "3. Verificando VCNs..."
VCN_COUNT=$(oci network vcn list --compartment-id $COMPARTMENT_ID --query 'length(data)' --raw-output)
echo "✓ $VCN_COUNT VCNs encontradas"

echo "=== Health Check Completo ==="
```

### Script de Backup de State
```bash
#!/bin/bash
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup do state
cp terraform.tfstate $BACKUP_DIR/terraform.tfstate_$TIMESTAMP
cp terraform.tfstate.backup $BACKUP_DIR/terraform.tfstate.backup_$TIMESTAMP

# Backup das variáveis
cp terraform.tfvars $BACKUP_DIR/terraform.tfvars_$TIMESTAMP

echo "Backup criado em $BACKUP_DIR com timestamp $TIMESTAMP"
```

## Variáveis de Ambiente Essenciais

```bash
# OCI CLI
export OCI_CLI_PROFILE=default
export OCI_CLI_CONFIG_FILE=~/.oci/config

# Terraform
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..aaaa..."
export TF_VAR_user_ocid="ocid1.user.oc1..aaaa..."
export TF_VAR_fingerprint="aa:bb:cc:dd:..."
export TF_VAR_private_key_path="~/.oci/oci_api_key.pem"
export TF_VAR_region="sa-saopaulo-1"
export TF_VAR_compartment_id="ocid1.compartment.oc1..aaaa..."

# Gerais
export COMPARTMENT_ID="ocid1.compartment.oc1..aaaa..."
export TENANCY_ID="ocid1.tenancy.oc1..aaaa..."
export OCI_USER_ID="ocid1.user.oc1..aaaa..."
```

## Troubleshooting Comum

### Problema: 401-NotAuthenticated
```bash
# Verificar chave privada
openssl rsa -check -in ~/.oci/oci_api_key.pem

# Verificar fingerprint
openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c

# Comparar com fingerprint no OCI Console
```

### Problema: Instância não consegue acessar internet
```bash
# Verificar route table
oci network route-table get --rt-id $ROUTE_TABLE_ID

# Verificar internet gateway
oci network internet-gateway get --ig-id $IG_ID

# Verificar security list rules
oci network security-list get --security-list-id $SECURITY_LIST_ID
```

### Problema: Terraform state locked
```bash
# Forçar unlock (usar com cuidado)
terraform force-unlock LOCK_ID

# Verificar locks
terraform state list
```

## Links Úteis

- [OCI Documentation](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest)
- [OCI CLI Documentation](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/)
- [OCI Training](https://learn.oracle.com/ols/learning-path/become-an-oci-architect-associate/35644/75658)
- [OCI Status](https://ocistatus.oraclecloud.com/)