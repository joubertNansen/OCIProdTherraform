# 🎓 Tutorial Completo: Terraform na Oracle Cloud (OCI)
**Guia Prático e Didático para Gerenciar Sua Infraestrutura**

---

## 📚 Índice
1. [Entendendo o Terraform - A Analogia da Planta Baixa](#1-entendendo-o-terraform)
2. [Listando Recursos Existentes - O Inventário](#2-listando-recursos-existentes)
3. [Adicionando Novos Recursos - Construindo Novas Peças](#3-adicionando-novos-recursos)
4. [Aplicando Mudanças - Atualizando o Projeto](#4-aplicando-mudanças)
5. [Removendo Recursos - Desmontando Peças](#5-removendo-recursos)
6. [Comandos Essenciais - Seu Kit de Ferramentas](#6-comandos-essenciais)
7. [Boas Práticas e Dicas](#7-boas-práticas-e-dicas)

---

## 1. Entendendo o Terraform - A Analogia da Planta Baixa

### 🏗️ O que é o Terraform?

Imagine que você está construindo uma casa:
- **Planta baixa** = Seus arquivos `.tf` (código Terraform)
- **Casa real** = Sua infraestrutura na OCI (VMs, redes, etc.)
- **Construtor** = Terraform (lê a planta e constrói/modifica a casa)
- **Diário de obras** = `terraform.tfstate` (registra o que já foi construído)

### 🎯 Como Funciona?

```
Você escreve a "planta" → Terraform compara com o "diário" → Executa mudanças → Atualiza o "diário"
    (arquivos .tf)          (terraform.tfstate)           (na OCI)         (terraform.tfstate)
```

### 📁 Estrutura do Seu Workspace

```
OCIProdTherraform/              OCINonProdTherraform/
├── main.tf                     ├── main.tf
├── variables.tf                ├── variables.tf
├── compartments.tf             ├── compartments.tf
├── vcn.tf                      ├── vcn.tf
├── instances.tf                ├── instances.tf
├── buckets.tf                  ├── buckets.tf
├── iam_policies.tf             ├── iam_policies.tf
├── terraform_prod.tfvars       ├── terraform_nonprod.tfvars
└── terraform.tfstate           └── terraform.tfstate
```

**O que cada arquivo faz:**
- `*.tf` = Receitas de como criar recursos (as plantas)
- `*.tfvars` = Valores específicos do ambiente (como "3 quartos" ou "2 quartos")
- `terraform.tfstate` = Registro do que foi criado (diário de obras)

---

## 2. Listando Recursos Existentes - O Inventário

### 🗂️ Analogia: Fazendo Inventário

Imagine que você acabou de herdar uma casa e quer saber exatamente o que tem nela. O Terraform tem vários "comandos de inspeção":

### 📋 Comando 1: Ver Tudo de Forma Simples

```bash
# Entre no diretório do ambiente
cd OCINonProdTherraform

# Liste todos os recursos gerenciados
terraform state list
```

**O que retorna (exemplo real do seu ambiente NONPROD):**
```
data.oci_core_images.chosen
data.oci_core_services.all_services
data.oci_identity_availability_domains.ads
data.oci_objectstorage_namespace.ns
oci_core_instance.project_instance["projeto-x-instance-1"]
oci_core_internet_gateway.igw
oci_core_nat_gateway.nat
oci_core_route_table.rt_private
oci_core_route_table.rt_public
oci_core_service_gateway.sgw
oci_core_subnet.private_shared
oci_core_subnet.project_subnet["projeto-x"]
oci_core_subnet.public_shared
oci_core_virtual_network.vcn_shared
oci_identity_compartment.child_level["projeto-a-nonprod"]
oci_identity_compartment.child_level["projeto-x-nonprod"]
oci_identity_compartment.child_level["shared-network-nonprod"]
oci_identity_compartment.root_level["nonprod"]
oci_identity_policy.project_policy["projeto-x"]
oci_objectstorage_bucket.project_bucket["projeto-x"]
```

**Tradução:** "Você tem esses 'cômodos' na sua casa OCI"

**⚠️ IMPORTANTE - Sintaxe no macOS/zsh:**
- **SEMPRE use aspas simples** ao redor do endereço completo
- Isso evita que o shell zsh interprete os colchetes `[]`

### 🔍 Comando 2: Ver Detalhes de Um Recurso Específico

```bash
# Ver detalhes completos de uma VM específica
# ⚠️ Note as aspas simples ao redor de TODO o endereço
terraform state show 'oci_core_instance.project_instance["projeto-x-instance-1"]'

# Ver detalhes de um compartimento
terraform state show 'oci_identity_compartment.child_level["projeto-x-nonprod"]'

# Ver detalhes de um bucket
terraform state show 'oci_objectstorage_bucket.project_bucket["projeto-x"]'
```

**❌ ERRADO (causa erro no zsh):**
```bash
# Sem aspas - zsh interpreta [] como padrão de glob
terraform state show oci_core_instance.project_instance["projeto-x-instance-1"]
# Resultado: zsh: no matches found

# Com crase ` (backtick) - sintaxe incorreta
terraform state show `oci_core_instance.project_instance["projeto-x-instance-1"]`
# Resultado: erro de sintaxe
```

**✅ CORRETO:**
```bash
# Com aspas simples ao redor de TUDO
terraform state show 'oci_core_instance.project_instance["projeto-x-instance-1"]'
```

**O que retorna:**
```hcl
# resource "oci_core_instance" "project_instance" {
    id                  = "ocid1.instance.oc1.sa-saopaulo-1...."
    display_name        = "instance-projeto-x-instance-1"
    compartment_id      = "ocid1.compartment.oc1....."
    shape               = "VM.Standard.A1.Flex"
    availability_domain = "aaaa:SA-SAOPAULO-1-AD-1"
    state               = "RUNNING"
    # ... mais detalhes
# }
```

**Tradução:** "Aqui estão todos os detalhes deste 'cômodo'"

**💡 Dica:** Use `grep` para filtrar informações específicas:
```bash
# Ver apenas nome e estado da VM
terraform state show 'oci_core_instance.project_instance["projeto-x-instance-1"]' | grep -E "display_name|state"

# Ver apenas IDs importantes  
terraform state show 'oci_core_instance.project_instance["projeto-x-instance-1"]' | grep -E "id|compartment_id|subnet_id"
```

### 📊 Comando 3: Ver Resumo Visual

```bash
# Ver toda a infraestrutura de forma estruturada
terraform show
```

**Analogia:** É como ter uma planta baixa anotada da casa, mostrando cada detalhe.

### 💡 Comando 4: Ver Outputs (Informações Importantes)

```bash
# Ver apenas as informações de saída (IDs importantes)
terraform output
```

**Retorna:**
```
compartment_ids = {
  "nonprod" = "ocid1.compartment.oc1....."
}
vcn_shared_id = "ocid1.vcn.oc1.sa-saopaulo-1....."
pub_subnet_shared_id = "ocid1.subnet.oc1.sa-saopaulo-1....."
```

**Tradução:** "Aqui estão os 'endereços' dos principais cômodos da casa"

### 🎯 Exemplo Prático: Descobrindo Sua Infraestrutura

```bash
# 1. Entre no ambiente NONPROD
cd /Users/joubertgabriel/Documents/CodePlace/oci_nansen_infrastructure/OCINonProdTherraform

# 2. Veja quantos recursos você tem
terraform state list | wc -l

# 3. Liste apenas as VMs (instances)
terraform state list | grep instance

# 4. Veja detalhes da sua VCN
terraform state show oci_core_virtual_network.vcn_shared

# 5. Veja detalhes de um compartimento específico (COM ASPAS SIMPLES!)
terraform state show 'oci_identity_compartment.child_level["projeto-x-nonprod"]'

# 6. Exporte outputs em JSON para processar
terraform output -json > outputs.json
```

---

## 3. Adicionando Novos Recursos - Construindo Novas Peças

### 🧱 Analogia: Montando LEGO

Adicionar recursos no Terraform é como adicionar peças LEGO:
1. Você **descreve a peça** no código (formato, cor, tamanho)
2. Terraform **planeja onde encaixar** a peça
3. Você **aprova o plano**
4. Terraform **encaixa a peça** de verdade

### 📝 Passo a Passo: Adicionar uma Nova VM

#### Etapa 1: Editar o Arquivo de Variáveis

Abra `terraform_nonprod.tfvars` e adicione:

```hcl
# Adicione esta nova VM ao mapa de instâncias existente
project_instances = {
  # VMs existentes (exemplo do seu ambiente atual)...
  "projeto-x-instance-1" = {
    compartment      = "projeto-x-nonprod"
    subnet           = "projeto-x"
    shape            = "VM.Standard.A1.Flex"
    ocpus            = 4
    memory_in_gbs    = 24
    assign_public_ip = false
  }
  
  # NOVA VM - adicione aqui
  "projeto-y-instance-1" = {
    compartment      = "nonprod"              # Compartimento onde vai ficar
    subnet           = "private_shared"       # Subnet onde vai conectar
    shape            = "VM.Standard.A1.Flex"  # Tamanho da máquina
    ocpus            = 2                      # 2 CPUs virtuais
    memory_in_gbs    = 12                     # 12 GB de RAM
    assign_public_ip = false                  # Não precisa de IP público
  }
}
```

**Tradução:** "Quero adicionar um novo 'cômodo' chamado projeto-y-instance-1 na casa"

**💡 Observação sobre nomes:** Note que usamos o padrão `projeto-nome-instance-N` para VMs, onde:
- `projeto-nome` = identificador do projeto
- `instance` = indica que é uma VM
- `N` = número sequencial (1, 2, 3...)

Isso ajuda a organizar quando você tem múltiplas VMs no mesmo projeto.

#### Etapa 2: Verificar o Que Vai Ser Criado (ANTES de criar!)

```bash
# Gere um plano para ver o que vai acontecer
terraform plan -var-file="terraform_nonprod.tfvars" -out=plano_nova_vm.tfplan
```

**O que o Terraform mostra:**
```
Terraform will perform the following actions:

  # oci_core_instance.project_instance["projeto-y-instance-1"] will be created
  + resource "oci_core_instance" "project_instance" {
      + display_name        = "instance-projeto-y-instance-1"
      + compartment_id      = (known after apply)
      + shape               = "VM.Standard.A1.Flex"
      + shape_config {
          + ocpus         = 2
          + memory_in_gbs = 12
        }
      # ... mais detalhes
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

**Tradução:** 
- ✅ "Vou **adicionar** 1 nova peça (a VM)"
- ✅ "Não vou **modificar** nada que já existe"
- ✅ "Não vou **destruir** nada"

#### Etapa 3: Aplicar a Mudança

```bash
# Aplique o plano que você revisou
terraform apply "plano_nova_vm.tfplan"
```

**O que acontece:**
```
oci_core_instance.project_instance["projeto-y-instance-1"]: Creating...
oci_core_instance.project_instance["projeto-y-instance-1"]: Still creating... [10s elapsed]
oci_core_instance.project_instance["projeto-y-instance-1"]: Still creating... [20s elapsed]
oci_core_instance.project_instance["projeto-y-instance-1"]: Creation complete after 32s

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

**Tradução:** "Construí a nova VM! Levou 32 segundos."

### 🎯 Exemplo Completo: Adicionar Subnet + VM + Bucket

```hcl
# Em terraform_nonprod.tfvars

# 1. Adicione uma nova subnet
project_subnets = {
  # Subnets existentes (exemplo do seu ambiente)...
  "projeto-x" = {
    cidr_block  = "10.0.10.0/24"
    public      = false
    compartment = "projeto-x-nonprod"
  }
  
  # NOVA SUBNET
  "projeto-novo" = {
    cidr_block  = "10.0.20.0/24"     # Faixa de IPs para esta rede
    public      = false               # Rede privada
    compartment = "nonprod"           # Compartimento pai
  }
}

# 2. Adicione uma VM nesta subnet
project_instances = {
  # VMs existentes...
  
  # NOVA VM
  "projeto-novo-app-instance-1" = {
    compartment   = "nonprod"
    subnet        = "projeto-novo"      # Usa a subnet que criamos acima
    shape         = "VM.Standard.A1.Flex"
    ocpus         = 1                   # 1 CPU virtual
    memory_in_gbs = 8                   # 8 GB de RAM
  }
}

# 3. Adicione um bucket para esta aplicação
project_buckets = {
  # Buckets existentes (exemplo: projeto-x)...
  
  # NOVO BUCKET
  "projeto-novo-storage" = {
    compartment = "nonprod"
    namespace   = ""                  # Usa o namespace padrão da tenancy
  }
}
```

**Comandos para aplicar:**
```bash
# 1. Valide a sintaxe
terraform validate

# 2. Veja o plano completo
terraform plan -var-file="terraform_nonprod.tfvars"

# 3. Se estiver tudo OK, aplique
terraform apply -var-file="terraform_nonprod.tfvars"
```

---

## 4. Aplicando Mudanças - Atualizando o Projeto

### 🔄 Analogia: Renovando a Casa

Aplicar mudanças é como reformar cômodos existentes sem demolir tudo.

### Tipos de Mudanças

1. **In-place updates** = Pintar uma parede (recurso continua o mesmo, só muda configuração)
2. **Replace** = Demolir e reconstruir um cômodo (recurso precisa ser recriado)

### 📝 Exemplo 1: Mudar o Nome de uma VM (In-place)

#### Antes:
```hcl
# Em instances.tf, a VM é criada assim:
resource "oci_core_instance" "project_instance" {
  for_each = var.project_instances
  display_name = "instance-${each.key}"  # Nome atual: instance-projeto-x-instance-1
  # ... outras configs
}
```

#### Mudança - Edite o arquivo:
```hcl
resource "oci_core_instance" "project_instance" {
  for_each = var.project_instances
  display_name = "vm-app-${each.key}"  # Novo nome: vm-app-projeto-x-instance-1
  # ... outras configs
}
```

#### Veja o plano:
```bash
terraform plan -var-file="terraform_nonprod.tfvars"
```

**Terraform mostra:**
```
  ~ resource "oci_core_instance" "project_instance" ["projeto-x-instance-1"] {
      ~ display_name = "instance-projeto-x-instance-1" -> "vm-app-projeto-x-instance-1"
        # (outros atributos permanecem inalterados)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

**Tradução:** 
- O símbolo `~` = "Vou **modificar** este recurso"
- `->` = "Mudando de... para..."
- **0 to destroy** = "Não vou apagar nada!"

#### Aplique:
```bash
terraform apply -var-file="terraform_nonprod.tfvars"
```

### 📝 Exemplo 2: Mudar o Shape de uma VM (Replace)

⚠️ **ATENÇÃO:** Mudar o shape geralmente requer recriar a VM!

#### Mudança no tfvars:
```hcl
project_instances = {
  "projeto-x-instance-1" = {
    compartment   = "projeto-x-nonprod"
    subnet        = "projeto-x"
    shape         = "VM.Standard.E4.Flex"  # MUDOU de VM.Standard.A1.Flex
    ocpus         = 2                       # Agora com 2 CPUs
    memory_in_gbs = 16                      # E 16 GB de RAM
  }
}
```

#### Veja o plano:
```bash
terraform plan -var-file="terraform_nonprod.tfvars"
```

**Terraform mostra:**
```
-/+ resource "oci_core_instance" "project_instance" ["projeto-x-instance-1"] {
      ~ shape              = "VM.Standard.A1.Flex" -> "VM.Standard.E4.Flex"
      # (forces replacement)
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

**Tradução:**
- `-/+` = "Vou **destruir e recriar** este recurso"
- **(forces replacement)** = "Mudança requer recriação"
- ⚠️ **CUIDADO:** A VM antiga será apagada!

### 🛡️ Como Evitar Surpresas: Use o Target

Se você quer mudar apenas UM recurso específico:

```bash
# Aplique mudança APENAS na VM projeto-x-instance-1
# ⚠️ LEMBRE-SE: Use aspas simples no macOS/zsh!
terraform apply -var-file="terraform_nonprod.tfvars" \
  -target='oci_core_instance.project_instance["projeto-x-instance-1"]'
```

---

## 5. Removendo Recursos - Desmontando Peças

### 🗑️ Analogia: Demolindo Cômodos

Remover recursos é como demolir partes da casa que você não quer mais.

### ⚠️ ATENÇÃO - Regras de Ouro

1. **SEMPRE faça backup do state antes de remover**
2. **SEMPRE use `plan` antes de `destroy`**
3. **Nunca destrua recursos em PROD sem revisão**

### Método 1: Remover do Código (Recomendado)

#### Passo 1: Comente ou Remova do tfvars

**Antes:**
```hcl
project_instances = {
  "projeto-x-instance-1" = { ... }
  "projeto-y-instance-1" = { ... }  # Vamos remover esta
}
```

**Depois:**
```hcl
project_instances = {
  "projeto-x-instance-1" = { ... }
  # "projeto-y-instance-1" removido - não queremos mais esta VM
}
```

#### Passo 2: Veja o Plano de Destruição

```bash
terraform plan -var-file="terraform_nonprod.tfvars"
```

**Terraform mostra:**
```
  - resource "oci_core_instance" "project_instance" ["projeto-y-instance-1"] {
      - display_name = "instance-projeto-y-instance-1" -> null
      # ... outros atributos sendo removidos
    }

Plan: 0 to add, 0 to change, 1 to destroy.
```

**Tradução:**
- `-` = "Vou **destruir** este recurso"
- `-> null` = "Este valor vai deixar de existir"

#### Passo 3: Aplique a Remoção

```bash
terraform apply -var-file="terraform_nonprod.tfvars"
```

### Método 2: Usar `terraform destroy` (Destruição Direcionada)

```bash
# Destruir APENAS um recurso específico
# ⚠️ Use aspas simples no macOS/zsh!
terraform destroy -var-file="terraform_nonprod.tfvars" \
  -target='oci_core_instance.project_instance["projeto-y-instance-1"]'
```

**Terraform pergunta:**
```
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: 
```

Digite `yes` para confirmar.

### Método 3: Remover do State Sem Destruir (Avançado)

⚠️ Use apenas se quiser PARAR de gerenciar um recurso sem apagá-lo da OCI:

```bash
# Remove do state, mas o recurso continua existindo na OCI
# ⚠️ Use aspas simples!
terraform state rm 'oci_core_instance.project_instance["projeto-y-instance-1"]'
```

**Quando usar:**
- Quando você quer gerenciar o recurso manualmente
- Quando está migrando para outro workspace
- ⚠️ **Cuidado:** Terraform não vai mais rastrear este recurso!

### 🎯 Exemplo Prático: Limpar Projeto Completo

```bash
# 1. Backup do estado atual
cp terraform.tfstate terraform.tfstate.backup.$(date +%Y%m%d_%H%M%S)

# 2. Edite terraform_nonprod.tfvars e remova:
# - A entrada em project_instances
# - A entrada em project_buckets
# - A entrada em project_subnets
# - A entrada em project_policies

# 3. Veja o plano (REVISE CUIDADOSAMENTE!)
terraform plan -var-file="terraform_nonprod.tfvars" -out=plano_limpeza.tfplan

# 4. Se estiver correto, aplique
terraform apply "plano_limpeza.tfplan"
```

---

## 6. Comandos Essenciais - Seu Kit de Ferramentas

### 🔧 Comandos do Dia a Dia

```bash
# ============================================
# PREPARAÇÃO
# ============================================

# Inicializar Terraform (primeira vez ou após mudar providers)
terraform init

# Validar sintaxe dos arquivos .tf
terraform validate

# Formatar código (deixar bonito e padronizado)
terraform fmt


# ============================================
# PLANEJAMENTO
# ============================================

# Ver o que vai mudar (SEMPRE use antes de apply!)
terraform plan -var-file="terraform_nonprod.tfvars"

# Salvar plano em arquivo para aplicar depois
terraform plan -var-file="terraform_nonprod.tfvars" -out=meu_plano.tfplan

# Ver plano de destruição
terraform plan -destroy -var-file="terraform_nonprod.tfvars"


# ============================================
# APLICAÇÃO
# ============================================

# Aplicar mudanças (pede confirmação)
terraform apply -var-file="terraform_nonprod.tfvars"

# Aplicar plano salvo (não pede confirmação)
terraform apply "meu_plano.tfplan"

# Aplicar sem pedir confirmação (CUIDADO!)
terraform apply -var-file="terraform_nonprod.tfvars" -auto-approve


# ============================================
# INSPEÇÃO
# ============================================

# Listar todos os recursos gerenciados
terraform state list

# Ver detalhes de um recurso
terraform state show 'oci_core_instance.project_instance["projeto-x-instance-1"]'

# Ver toda a infraestrutura
terraform show

# Ver outputs
terraform output

# Ver output específico
terraform output vcn_shared_id


# ============================================
# MANIPULAÇÃO DE STATE
# ============================================

# Mover recurso no state (renomear)
terraform state mv 'oci_core_instance.old["x"]' 'oci_core_instance.new["x"]'

# Remover recurso do state (sem destruir na OCI)
terraform state rm 'oci_core_instance.project_instance["projeto-x-instance-1"]'

# Puxar state para arquivo local
terraform state pull > estado_atual.json

# Importar recurso existente para o state
terraform import 'oci_core_instance.nova_vm' ocid1.instance.oc1...


# ============================================
# DESTRUIÇÃO
# ============================================

# Destruir recurso específico (use aspas simples!)
terraform destroy -target='oci_core_instance.project_instance["projeto-x-instance-1"]'

# Destruir tudo (MUITO CUIDADO!)
terraform destroy -var-file="terraform_nonprod.tfvars"


# ============================================
# TROUBLESHOOTING
# ============================================

# Ver logs detalhados
TF_LOG=DEBUG terraform plan

# Atualizar state sem modificar infraestrutura
terraform refresh

# "Desbloquear" state travado
terraform force-unlock LOCK_ID
```

### 📊 Workflow Recomendado

```bash
# Workflow completo para fazer uma mudança:

# 1. Edite os arquivos necessários (*.tf ou *.tfvars)
code terraform_nonprod.tfvars

# 2. Valide a sintaxe
terraform validate

# 3. Formate o código
terraform fmt

# 4. Veja o que vai mudar
terraform plan -var-file="terraform_nonprod.tfvars" -out=plano.tfplan

# 5. Revise o plano com calma
terraform show plano.tfplan

# 6. Se estiver OK, aplique
terraform apply "plano.tfplan"

# 7. Confirme que funcionou
terraform state list
terraform output
```

---

## 7. Boas Práticas e Dicas

### ✅ Regras de Ouro

#### 1. **SEMPRE use `plan` antes de `apply`**
```bash
# ❌ NUNCA faça isso direto
terraform apply -auto-approve

# ✅ SEMPRE faça assim
terraform plan -out=plano.tfplan
# Revise o plano
terraform apply "plano.tfplan"
```

#### 2. **Use variáveis para valores que mudam**
```hcl
# ❌ Ruim - valor fixo no código
resource "oci_core_instance" "vm" {
  shape = "VM.Standard2.1"
}

# ✅ Bom - valor vem de variável
resource "oci_core_instance" "vm" {
  shape = var.instance_shape
}
```

#### 3. **Nomeie recursos de forma descritiva**
```hcl
# ❌ Ruim
project_instances = {
  "vm1" = { ... }
  "vm2" = { ... }
}

# ✅ Bom
project_instances = {
  "webapp-frontend" = { ... }
  "webapp-backend" = { ... }
}
```

#### 4. **Faça backup do state antes de mudanças grandes**
```bash
# Sempre antes de destroy ou mudanças complexas
cp terraform.tfstate terraform.tfstate.backup.$(date +%Y%m%d_%H%M%S)
```

#### 5. **Use comentários para documentar decisões**
```hcl
# Usamos VM.Standard2.1 porque VM.Standard.E4.Flex
# não estava disponível na região sa-saopaulo-1 em Nov/2025
project_instances = {
  "app" = {
    shape = "VM.Standard2.1"
  }
}
```

### 🎯 Organização do Workspace

```
Estrutura Recomendada:
├── *.tf              # Código Terraform (versionado no Git)
├── *.tfvars          # Variáveis (NÃO versionar se tiver secrets)
├── terraform.tfstate # State (usar backend remoto em produção)
├── .terraform/       # Cache (adicionar ao .gitignore)
└── *.tfplan          # Planos salvos (adicionar ao .gitignore)
```

### 🚨 Erros Comuns e Como Evitar

#### Erro 1: "Resource already exists"
**Causa:** Tentando criar algo que já existe na OCI mas não está no state.

**Solução:**
```bash
# Importe o recurso existente
terraform import 'oci_core_instance.vm["nova"]' ocid1.instance.oc1...
```

#### Erro 2: "Invalid index"
**Causa:** Tentando acessar um recurso que não existe no map.

**Solução:**
```hcl
# ❌ Ruim
compartment_id = oci_identity_compartment.child["projeto-z"].id

# ✅ Bom - verifica se existe
compartment_id = contains(keys(oci_identity_compartment.child), "projeto-z") ? 
  oci_identity_compartment.child["projeto-z"].id : var.default_compartment_id
```

#### Erro 3: "State lock"
**Causa:** Dois processos tentando modificar o state ao mesmo tempo.

**Solução:**
```bash
# Se você tem certeza que não há outro processo rodando
terraform force-unlock <LOCK_ID>
```

#### Erro 4: "Shape not available"
**Causa:** O shape escolhido não está disponível no AD/região.

**Solução:**
```bash
# Liste shapes disponíveis
oci compute shape list --compartment-id <compartment-ocid> --availability-domain <AD>

# Ou use data source no Terraform
data "oci_core_shapes" "available" {
  compartment_id = var.compartment_id
}
```

### 📝 Checklist Antes de Apply em Produção

- [ ] Testei a mudança em NONPROD primeiro?
- [ ] Revisei o `terraform plan` linha por linha?
- [ ] Fiz backup do `terraform.tfstate`?
- [ ] Avisei o time sobre a mudança?
- [ ] Tenho rollback plan se algo der errado?
- [ ] É fora do horário de pico?
- [ ] Salvei o plano em arquivo antes de aplicar?

---

## 🎓 Exercícios Práticos

### Exercício 1: Inventário Básico
```bash
# Objetivo: Conhecer sua infraestrutura atual

cd OCINonProdTherraform

# 1. Liste todos os recursos
terraform state list

# 2. Conte quantos recursos você tem
terraform state list | wc -l

# 3. Veja detalhes da VCN
terraform state show oci_core_virtual_network.vcn_shared

# 4. Exporte outputs
terraform output -json > meus_outputs.json
```

### Exercício 2: Adicionar Recurso Simples
```bash
# Objetivo: Criar um novo bucket

# 1. Edite terraform_nonprod.tfvars
# Adicione:
# project_buckets = {
#   "teste-bucket" = {
#     compartment = "nonprod"
#   }
# }

# 2. Veja o plano
terraform plan -var-file="terraform_nonprod.tfvars"

# 3. Aplique
terraform apply -var-file="terraform_nonprod.tfvars"

# 4. Confirme que foi criado
terraform state list | grep bucket
```

### Exercício 3: Modificar Recurso
```bash
# Objetivo: Mudar nome de display de uma subnet

# 1. Veja o nome atual
terraform state show oci_core_subnet.public_shared | grep display_name

# 2. Edite vcn.tf e mude o display_name

# 3. Veja o que vai mudar
terraform plan -var-file="terraform_nonprod.tfvars"

# 4. Aplique
terraform apply -var-file="terraform_nonprod.tfvars"
```

### Exercício 4: Remover Recurso
```bash
# Objetivo: Remover o bucket de teste

# 1. Remova a entrada do terraform_nonprod.tfvars

# 2. Veja o plano de destruição
terraform plan -var-file="terraform_nonprod.tfvars"

# 3. Confirme que vai destruir APENAS o bucket
# Procure por: Plan: 0 to add, 0 to change, 1 to destroy

# 4. Aplique
terraform apply -var-file="terraform_nonprod.tfvars"
```

---

## 📚 Recursos Adicionais

### Documentação Oficial
- [Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [OCI CLI Reference](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

### Comandos Úteis de Referência Rápida

```bash
# Ver versão do Terraform
terraform version

# Atualizar providers
terraform init -upgrade

# Ver configuração atual
terraform show

# Gerar gráfico de dependências (requer graphviz)
terraform graph | dot -Tpng > graph.png

# Validar com logs detalhados
TF_LOG=TRACE terraform validate

# Limpar cache local
rm -rf .terraform
```

### Dicas de Produtividade

1. **Use alias para comandos frequentes:**
```bash
# Adicione ao seu ~/.zshrc ou ~/.bashrc
alias tf='terraform'
alias tfp='terraform plan -var-file="terraform_nonprod.tfvars"'
alias tfa='terraform apply'
alias tfs='terraform state list'
```

2. **Configure auto-complete:**
```bash
terraform -install-autocomplete
```

3. **Use VS Code com extensão Terraform:**
- Instale: HashiCorp Terraform
- Syntax highlighting automático
- Autocomplete de recursos
- Formatação automática

---

## 🎯 Resumo Final

### O que você aprendeu:

✅ **Listar recursos:** `terraform state list`, `terraform show`, `terraform output`  
✅ **Adicionar recursos:** Editar `.tfvars` → `plan` → revisar → `apply`  
✅ **Modificar recursos:** Editar código → `plan` → revisar mudanças → `apply`  
✅ **Remover recursos:** Remover do código → `plan -destroy` → revisar → `apply`  

### Fluxo de Trabalho Ideal:

```
1. Edite código/variáveis
2. terraform validate
3. terraform fmt
4. terraform plan -out=plano.tfplan
5. Revise o plano COM CALMA
6. terraform apply "plano.tfplan"
7. Verifique resultado com state/output
```

### Próximos Passos:

1. ✅ Pratique os exercícios deste tutorial
2. ✅ Faça mudanças pequenas e incrementais
3. ✅ Sempre teste em NONPROD primeiro
4. ✅ Documente suas decisões em comentários
5. ✅ Mantenha backups do state
6. ✅ Versione seu código no Git

---

**Lembre-se:** Terraform é uma ferramenta poderosa. Use sempre `plan` antes de `apply`, teste em NONPROD antes de PROD, e nunca tenha medo de pedir ajuda ou revisar a documentação!

🎉 **Parabéns!** Agora você tem as ferramentas para gerenciar sua infraestrutura OCI com confiança!

---

**Tutorial criado em:** 18/12/2025  
**Baseado no workspace:** oci_nansen_infrastructure  
**Ambientes:** OCIProdTherraform e OCINonProdTherraform
