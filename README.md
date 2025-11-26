# OCIProdTerraform 🚀## OCIProdTerraform



Infraestrutura como Código (IaC) para provisionar um ambiente **produção** completo na **Oracle Cloud Infrastructure (OCI)** usando Terraform.Repositório com módulo Terraform que cria infra básica na Oracle Cloud

Infrastructure (OCI). Contém recursos parametrizados para:

## 📋 Índice

- Compartimentos (compartments)

- [O que é esta aplicação?](#o-que-é-esta-aplicação)- VCN e subnets

- [Arquitetura](#arquitetura)- Instâncias (VMs)

- [Pré-requisitos](#pré-requisitos)- Buckets de Object Storage

- [Instalação](#instalação)- Bancos de dados (DB systems)

- [Configuração](#configuração)- Políticas IAM por projeto

- [Uso](#uso)

- [Estrutura de Arquivos](#estrutura-de-arquivos)Arquivos principais:

- [Variáveis Disponíveis](#variáveis-disponíveis)- `main.tf` - provider e invocação do módulo

- [Segurança](#segurança)- `variables.tf` - declarações de variáveis

- [Troubleshooting](#troubleshooting)- `buckets.tf`, `instances.tf`, `databases.tf`, `iam_policies.tf` - recursos

- `terraform_prod.tfvars` - exemplo de valores para ambiente de produção

---- `cost_allocation.py` - script auxiliar demonstrativo (rateio de custos)

- `push.sh` / `push.ps1` - scripts para facilitar commits/push

## O que é esta aplicação?

Leia os comentários nos arquivos `.tf` e no `terraform_prod.tfvars` para

Esta aplicação Terraform automatiza a criação e gerenciamento de recursos na Oracle Cloud Infrastructure (OCI), incluindo:entender como parametrizar o deploy.



✅ **Rede Virtual (VCN)** com sub-redes públicas e privadas  ## Como executar o deploy (exemplo rápido)

✅ **Máquinas Virtuais (Instâncias)** para executar aplicações  

✅ **Banco de Dados** (Oracle Database) em sub-rede privada  Aviso: este repositório contém exemplos com valores de produção fictícios.

✅ **Armazenamento em Objeto** (Buckets) para arquivos e backups  Não rode `terraform apply` em um ambiente real sem antes revisar as variáveis

✅ **Políticas de Acesso (IAM)** para controlar permissões  e confirmar que você tem autorização para criar recursos na conta OCI.

✅ **Script de Rateio de Custos** para alocar custos compartilhados entre projetos  

1. Configure as credenciais do provider OCI

**Ambiente:** Produção (aplicações críticas)  

**Região Padrão:** São Paulo (`sa-saopaulo-1`)  - Opção 1 — usar `terraform_prod.tfvars` (já existe no repositório):

**Provedor:** Oracle Cloud Infrastructure (OCI)	- Edite `terraform_prod.tfvars` e preencha os campos `tenancy_ocid`, `user_ocid`,

		`fingerprint`, `private_key_path` e `region` com os valores corretos.

---

- Opção 2 — usar variáveis de ambiente ou mecanismo de secrets (recomendado

## Arquitetura	em CI): defina as variáveis necessárias e prefira não commitar valores sensíveis.



```2. Inicializar o Terraform

┌─────────────────────────────────────────────────────────────┐

│                  Oracle Cloud (OCI)                         │No Windows PowerShell (na pasta do repositório):

│                  Região: São Paulo                          │

├─────────────────────────────────────────────────────────────┤```powershell

│                                                             │terraform init

│  ┌──────────────────────────────────────────────────────┐  │```

│  │  VCN (Rede Virtual) - 10.1.0.0/16                   │  │

│  │                                                      │  │3. Validar e planejar

│  │  ┌─────────────────────┐  ┌─────────────────────┐  │  │

│  │  │ Sub-rede Pública    │  │ Sub-rede Privada    │  │  │```powershell

│  │  │ 10.1.1.0/24         │  │ 10.1.2.0/24         │  │  │terraform validate

│  │  │                     │  │                     │  │  │terraform plan -var-file="terraform_prod.tfvars" -out=tfplan

│  │  │ ┌─────────────────┐ │  │ ┌─────────────────┐ │  │  │```

│  │  │ │  Instância VM   │ │  │ │  Banco de Dados │ │  │  │

│  │  │ │ (Aplicação Web) │ │  │ │  (Oracle DB)    │ │  │  │4. Aplicar o plano (revise o `tfplan` antes de aplicar)

│  │  │ └─────────────────┘ │  │ └─────────────────┘ │  │  │

│  │  └─────────────────────┘  └─────────────────────┘  │  │```powershell

│  └──────────────────────────────────────────────────────┘  │terraform apply "tfplan"

│                                                             │```

│  ┌──────────────────────────────────────────────────────┐  │

│  │  Object Storage                                      │  │5. Pós-deploy

│  │  ┌────────────────────────────────────────────────┐ │  │

│  │  │ Bucket (Armazenamento de arquivos, logs)      │ │  │- Verifique no Console OCI os recursos criados (VCN, subnets, instâncias,

│  │  └────────────────────────────────────────────────┘ │  │	buckets e DB systems) e confirme que estão nos compartments corretos.

│  └──────────────────────────────────────────────────────┘  │

│                                                             │## Uso dos scripts de commit/push

│  Compartimentos:                                            │

│  • prod (raiz)                                              │- `push.sh` — script Bash (Linux/macOS)

│  • shared-network-prod (rede compartilhada)                │- `push.ps1` — script PowerShell (Windows). Exemplo de uso no PowerShell:

│  • projeto-a-prod (recursos específicos do projeto)        │

│                                                             │```powershell

└─────────────────────────────────────────────────────────────┘.\push.ps1

``````



---## Notas de segurança e boas práticas



## Pré-requisitos- Nunca armazene chaves privadas diretamente no repositório. Mova chaves para

	`%USERPROFILE%\.ssh` e adicione `key`/padrões ao `.gitignore` (já configurado).

Você precisa ter instalado e configurado:- Senhas e secrets (ex.: `admin_password` em `terraform_prod.tfvars`) devem ser

	gerenciadas via mecanismo seguro (Vault, OCI Vault, variables de pipeline),

### 1. **Terraform** (v1.0+)	e não commitadas em texto claro no repo.

```bash- Considere usar SSH com `ssh-agent` ou Git Credential Manager para autenticação

# Verificar instalação	com o Git. No Windows, inicie e habilite o serviço `ssh-agent` se usar chaves SSH.

terraform --version

## Restauração / limpeza

# Download: https://www.terraform.io/downloads

```- Para desfazer: rode `terraform destroy -var-file="terraform_prod.tfvars"` —

	revise antes de executar pois irá remover recursos.

### 2. **Oracle Cloud CLI** (opcional, mas recomendado)

```bash## Perguntas frequentes (rápidas)

# Verificar instalação

oci --version- Posso rodar isso localmente? Sim, se tiver acesso e permissões na tenancy OCI.

- Como evitar custos? Teste primeiro em uma tenancy de desenvolvimento e

# Download: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/climanualinst.htm	remova recursos após o teste (`terraform destroy`).

```

---

### 3. **Credenciais OCI**

```bash
# Gerar chave privada (se ainda não tiver)
# Via OCI Console → User Profile → API Keys → Add API Key
# Salvar em: ~/.oci/prod_api_key.pem

# Verificar permissões
chmod 600 ~/.oci/prod_api_key.pem
```

### 4. **Git** (para clonar/trabalhar com repositório)
```bash
# Verificar instalação
git --version
```

### 5. **Python 3.7+** (para executar script de rateio de custos)
```bash
# Verificar instalação
python --version
```

---

## Instalação

### 1️⃣ Clonar o Repositório

```bash
git clone https://github.com/joubertNansen/OCIProdTherraform.git
cd OCIProdTherraform
```

### 2️⃣ Verificar Estrutura de Arquivos

```bash
ls -la
# Esperado:
# - main.tf
# - variables.tf
# - terraform_prod.tfvars
# - buckets.tf
# - databases.tf
# - instances.tf
# - iam_policies.tf
# - cost_allocation.py
# - README.md
```

### 3️⃣ Inicializar Terraform

```bash
# Baixa plugins necessários e prepara ambiente
terraform init
```

---

## Configuração

### 1️⃣ Editar Arquivo de Valores

Abra `terraform_prod.tfvars` e atualize com seus dados OCI:

```hcl
# Sua região OCI (ex: sa-saopaulo-1, us-ashburn-1)
region           = "sa-saopaulo-1"

# Seu OCID de tenancy (encontrar em OCI Console → Admin → Tenancy Details)
tenancy_ocid     = "ocid1.tenancy.oc1..XXXXX"

# Seu OCID de usuário (OCI Console → Profile → Copy Your User OCID)
user_ocid        = "ocid1.user.oc1..XXXXX"

# Fingerprint da sua chave pública (OCI Console → API Keys)
fingerprint      = "XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX"

# Caminho da sua chave privada
private_key_path = "~/.oci/prod_api_key.pem"

# Resto das configurações...
```

### 2️⃣ Validar Configuração

```bash
# Verifica sintaxe do código Terraform
terraform fmt -check

# Valida se a configuração está correta
terraform validate
```

### 3️⃣ Visualizar Plano de Execução

```bash
# Mostra quais recursos serão criados/modificados
terraform plan -out=tfplan

# Salva em arquivo para aplicar depois
```

---

## Uso

### ▶️ Aplicar Infraestrutura

```bash
# Criar todos os recursos
terraform apply tfplan

# OU, sem salvar em arquivo:
terraform apply

# Digite "yes" quando solicitado para confirmar
```

### ⏸️ Consultar Estado

```bash
# Listar recursos criados
terraform state list

# Detalhes de um recurso específico
terraform state show 'oci_core_instance.project_instance["projeto-a-prod"]'
```

### 🔄 Modificar Recursos

```bash
# Editar terraform_prod.tfvars com novas configurações

# Visualizar mudanças
terraform plan

# Aplicar mudanças
terraform apply
```

### 🗑️ Destruir Infraestrutura

```bash
# ⚠️ ATENÇÃO: Isto deletará TODOS os recursos na OCI!
terraform destroy

# Confirmar digitando "yes"
```

### 💰 Calcular Rateio de Custos

```bash
# Executar script Python para rateio
python cost_allocation.py

# Output esperado:
# projeto-a: R$ 1000.0
# projeto-b: R$ 500.0
# projeto-c: R$ 1500.0
```

---

## Estrutura de Arquivos

| Arquivo | Descrição |
|---------|-----------|
| `main.tf` | Configuração do provedor OCI e módulo principal |
| `variables.tf` | Definição de todas as variáveis (parâmetros) |
| `terraform_prod.tfvars` | Valores das variáveis (dados reais) |
| `iam_policies.tf` | Políticas de acesso e permissões |
| `instances.tf` | Máquinas virtuais |
| `buckets.tf` | Armazenamento em objeto (Object Storage) |
| `databases.tf` | Bancos de dados Oracle |
| `cost_allocation.py` | Script para rateio de custos |
| `README.md` | Este arquivo (documentação) |

---

## Variáveis Disponíveis

### Autenticação
```hcl
tenancy_ocid     # ID do inquilino OCI
user_ocid        # ID do usuário OCI
fingerprint      # Impressão digital da chave
private_key_path # Caminho da chave privada
region           # Região geográfica
```

### Rede
```hcl
compartments     # Divisões lógicas da conta
vcn_cidr         # Faixa IP da rede virtual (ex: 10.1.0.0/16)
subnet_cidrs     # Faixas IP das sub-redes (pública/privada)
```

### Acesso
```hcl
project_policies # Permissões por projeto
```

### Computação
```hcl
project_instances # Máquinas virtuais
  - availability_domain  # Zona de disponibilidade
  - compartment_id       # Compartimento
  - shape                # Tipo/tamanho (VM.Standard.E4.Flex)
  - subnet_id            # Sub-rede
  - image_id             # Imagem do SO
```

### Armazenamento
```hcl
project_buckets  # Buckets de armazenamento
  - compartment_id # Compartimento
  - namespace      # Namespace do bucket
```

### Banco de Dados
```hcl
project_databases # Bancos de dados
  - availability_domain  # Zona de disponibilidade
  - compartment_id       # Compartimento
  - shape                # Tamanho da VM
  - subnet_id            # Sub-rede (PRIVADA!)
  - database_edition     # STANDARD_EDITION ou ENTERPRISE_EDITION
  - db_name              # Nome do banco
  - admin_password       # Senha (⚠️ Usar vault!)
```

---

## Segurança

⚠️ **IMPORTANTE: Boas práticas de segurança**

### 1. **Nunca comitar informações sensíveis em público**

```bash
# NUNCA fazer commit de:
# - Chaves privadas
# - Senhas em plain text
# - OCIDs reais
# - Fingerprints

# Usar .gitignore para excluir arquivos sensíveis:
echo "terraform_prod.tfvars" >> .gitignore
echo "*.pem" >> .gitignore
```

### 2. **Usar Vault para Senhas**

Em vez de armazenar senhas em `terraform_prod.tfvars`, use:

```bash
# Option 1: Variáveis de ambiente
export TF_VAR_admin_password="SenhaSegura123!"
terraform apply

# Option 2: Arquivo .tfvars separado (não comitar)
terraform apply -var-file="secrets.tfvars"

# Option 3: Oracle Vault (recomendado)
# Criar secret em OCI → Vault → Create Secret
# Referenciar em Terraform
```

### 3. **Proteger Estado Terraform**

O arquivo `terraform.tfstate` contém informações sensíveis:

```bash
# NUNCA comitar terraform.tfstate
echo "terraform.tfstate*" >> .gitignore

# Usar backend remoto (TF Cloud, S3, etc)
# Exemplo com OCI Object Storage:
# Ver documentação oficial
```

### 4. **Usar Políticas IAM Restritivas**

```hcl
# Exemplo: Permitir apenas o necessário
statements = [
  "Allow group Devs to manage all-resources in compartment projeto-a-prod",
  "Allow group Devs to use virtual-network-family in compartment shared-network-prod"
]
```

---

## Comandos Úteis

### 📊 Planejar mudanças
```bash
terraform plan
terraform plan -out=tfplan
```

### ✅ Aplicar mudanças
```bash
terraform apply
terraform apply tfplan
```

### 🔍 Listar recursos
```bash
terraform state list
terraform state show <resource>
```

### 🗂️ Formatar código
```bash
terraform fmt
terraform fmt -recursive
```

### 🔧 Validar código
```bash
terraform validate
```

### 📝 Gráfico de dependências
```bash
terraform graph | dot -Tsvg > graph.svg
```

### 🗑️ Destruir recursos
```bash
terraform destroy
terraform destroy -target=<resource>  # Deletar apenas um recurso
```

### 📋 Saída de valores
```bash
terraform output
terraform output -json
```

---

## Troubleshooting

### ❌ "Error: Provider authentication unsuccessful"

**Solução:**
- Verificar se caminho `private_key_path` está correto
- Verificar permissões: `chmod 600 ~/.oci/prod_api_key.pem`
- Verificar OCIDs em `terraform_prod.tfvars`

```bash
# Testar autenticação OCI CLI
oci iam user get --user-id <seu_user_ocid>
```

### ❌ "Error: Invalid OCID"

**Solução:**
- Copiar OCIDs corretos do OCI Console
- Verificar se OCIDs não têm espaços extras

```bash
# Formato correto de OCID:
ocid1.tenancy.oc1..XXXXXXXXXXXXXXX
ocid1.user.oc1..XXXXXXXXXXXXXXX
ocid1.compartment.oc1..XXXXXXXXXXXXXXX
```

### ❌ "Error: Resource already exists"

**Solução:**
```bash
# Atualizar estado local
terraform refresh

# OU destruir e recricar
terraform destroy
terraform apply
```

### ❌ "Error: Insufficient permissions"

**Solução:**
- Verificar IAM policies do usuário no OCI Console
- Usuário precisa de permissões para: gerenciar redes, máquinas, bancos, storage

### ❌ "terraform init failed"

**Solução:**
```bash
# Limpar cache local
rm -rf .terraform

# Reinicializar
terraform init
```

---

## Próximos Passos

1. ✅ **Alta Disponibilidade**: Adicionar mais zonas de disponibilidade
2. ✅ **Load Balancer**: Adicionar balanceador de carga
3. ✅ **Auto Scaling**: Configurar escalabilidade automática
4. ✅ **Monitoramento**: Integrar com OCI Monitoring/Logging
5. ✅ **Backup Automático**: Configurar snapshots dos bancos
6. ✅ **Múltiplos Ambientes**: Usar workspaces Terraform para prod/staging

---

## Recursos Úteis

📚 **Documentação Oficial:**
- [Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Oracle Cloud Infrastructure Docs](https://docs.oracle.com/iaas/)
- [Terraform Best Practices](https://www.terraform.io/cloud-docs/best-practices)

🎓 **Tutoriais:**
- [Terraform Learning](https://learn.hashicorp.com/terraform)
- [OCI Terraform Examples](https://github.com/oracle/terraform-provider-oci/tree/master/examples)

---

## Licença

Este projeto é fornecido como está. Use por sua conta e risco.

---

## Suporte

Para dúvidas ou problemas:
1. Consultar [Issues do GitHub](https://github.com/joubertNansen/OCIProdTherraform/issues)
2. Revisar logs: `terraform show`
3. Ativar debug: `export TF_LOG=DEBUG`

---

**Última atualização:** Novembro de 2025  
**Autor:** Jobert Nansen  
**Status:** ✅ Pronto para uso
