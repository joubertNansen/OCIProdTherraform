# Resumo Completo dos Ambientes OCI
**Data:** 18 de dezembro de 2025  
**Infraestrutura:** Oracle Cloud Infrastructure (OCI)  
**Região:** sa-saopaulo-1

---

## 📊 Visão Geral

### Estatísticas Gerais

| Ambiente | Total de Recursos | Compartimentos | VCN | Subnets | VMs | Buckets | Políticas |
|----------|-------------------|----------------|-----|---------|-----|---------|-----------|
| **PROD** | 13 | 1 | 1 | 2 | 0 | 0 | 0 |
| **NONPROD** | 20 | 4 | 1 | 3 | 1 | 1 | 1 |
| **TOTAL** | **33** | **5** | **2** | **5** | **1** | **1** | **1** |

---

## 🏢 AMBIENTE PROD

### Status
✅ **Infraestrutura Base Pronta**  
⏳ **Aguardando Provisionamento de Aplicações**

### Recursos Criados (13 total)

#### 1️⃣ Compartimentos
```
Tenancy Root (Nansen Sistemas)
└── PROD
    OCID: ocid1.compartment.oc1..aaaaaaaa5i7sfaqrneykgkfbxkjaxkqgq7cdu6anpfzedk7f4g6l2vrwgl5a
    Tipo: Compartimento Root
    Status: Ativo
```

#### 2️⃣ Rede Virtual (VCN)
```
SHARED-VCN-PROD
├── OCID: ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaaezgfvpaabvstruavj27d3t7bhsvs62gqi7amgdfw3d5dffdrcgja
├── CIDR Block: 10.0.0.0/16 (estimado)
├── Região: sa-saopaulo-1
└── Compartimento: PROD
```

#### 3️⃣ Gateways de Conectividade
- **Internet Gateway (IGW-SHARED-PROD)**
  - Permite tráfego público de entrada/saída
  - Status: Enabled
  
- **NAT Gateway (NAT-SHARED-PROD)**
  - Permite tráfego privado de saída para internet
  - Status: Ativo
  
- **Service Gateway (SGW-SHARED-PROD)**
  - Conectividade com serviços OCI internos
  - Status: Ativo

#### 4️⃣ Tabelas de Roteamento
- **RT-PUBLIC-SHARED-PROD**
  - Rota padrão: 0.0.0.0/0 → Internet Gateway
  - Uso: Subnet pública
  
- **RT-PRIVATE-SHARED-PROD**
  - Rota padrão: 0.0.0.0/0 → NAT Gateway
  - Rota de serviço: Service Gateway (condicional)
  - Uso: Subnet privada

#### 5️⃣ Subnets
```
1. subnet-pub-shared-prod
   ├── OCID: ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaazvn3qzsindn3qpdom5p63dpbxnryjjfbbyvp4cvmat4agtv6pm5q
   ├── CIDR: 10.0.1.0/24 (254 IPs disponíveis)
   ├── Tipo: Pública
   ├── Route Table: RT-PUBLIC-SHARED-PROD
   └── IP Público: Permitido

2. subnet-priv-shared-prod
   ├── OCID: ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaa2cl2lkevjubmwxe66boylgz6ayauy5fj7xncx7ketaop2mystwka
   ├── CIDR: 10.0.2.0/24 (254 IPs disponíveis)
   ├── Tipo: Privada
   ├── Route Table: RT-PRIVATE-SHARED-PROD
   └── IP Público: Proibido
```

### Organograma PROD

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Tenancy: Nansen Sistemas                         │
│                  (ocid1.tenancy.oc1..aaaaaaaaehlq...)               │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
                    ┌─────────────────────────┐
                    │   Compartment: PROD     │
                    │  (Root Level)           │
                    └─────────────────────────┘
                                  │
                                  ▼
            ┌─────────────────────────────────────────┐
            │      SHARED-VCN-PROD (10.0.0.0/16)     │
            └─────────────────────────────────────────┘
                      │                    │
        ┌─────────────┴──────┐   ┌─────────┴──────────┐
        │                    │   │                    │
        ▼                    ▼   ▼                    ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ IGW (Public) │    │ NAT (Private)│    │ SGW (Service)│
└──────────────┘    └──────────────┘    └──────────────┘
        │                    │                    
        ▼                    ▼                    
┌──────────────┐    ┌──────────────┐             
│  RT-PUBLIC   │    │  RT-PRIVATE  │             
└──────────────┘    └──────────────┘             
        │                    │                    
        ▼                    ▼                    
┌──────────────┐    ┌──────────────┐             
│ subnet-pub-  │    │ subnet-priv- │             
│ shared-prod  │    │ shared-prod  │             
│ (10.0.1.0/24)│    │ (10.0.2.0/24)│             
└──────────────┘    └──────────────┘             
        │                    │                    
        ▼                    ▼                    
   [Sem VMs]           [Sem VMs]                 
```

---

## 🧪 AMBIENTE NONPROD

### Status
✅ **Infraestrutura Completa e Funcional**  
✅ **Ambiente de Teste com Projeto Exemplo Ativo**

### Recursos Criados (20 total)

#### 1️⃣ Compartimentos (4 níveis)
```
Tenancy Root (Nansen Sistemas)
└── NONPROD
    ├── OCID: ocid1.compartment.oc1..aaaaaaaa57voziabju2jz4vv7pxkudy3eya6qrnyayoo4xwqiodcew3kqsnq
    ├── Tipo: Compartimento Root
    └── Compartimentos Filhos (3):
        ├── Projeto X (compartimento filho)
        ├── Projeto Y (compartimento filho)
        └── Projeto Z (compartimento filho)
```

#### 2️⃣ Rede Virtual (VCN)
```
SHARED-VCN-NONPROD
├── OCID: ocid1.vcn.oc1.sa-saopaulo-1.amaaaaaaezgfvpaamwcimwlads56irzrf66rca7c2de3ve6pp53k6mvigkeq
├── CIDR Block: 10.0.0.0/16 (estimado)
├── Região: sa-saopaulo-1
└── Compartimento: NONPROD
```

#### 3️⃣ Gateways de Conectividade
- **Internet Gateway (IGW-SHARED-NONPROD)**
  - Permite tráfego público de entrada/saída
  - Status: Enabled
  
- **NAT Gateway (NAT-SHARED-NONPROD)**
  - Permite tráfego privado de saída para internet
  - Status: Ativo
  
- **Service Gateway (SGW-SHARED-NONPROD)**
  - Conectividade com serviços OCI internos
  - Status: Ativo

#### 4️⃣ Tabelas de Roteamento
- **RT-PUBLIC-SHARED-NONPROD**
  - Rota padrão: 0.0.0.0/0 → Internet Gateway
  - Uso: Subnet pública
  
- **RT-PRIVATE-SHARED-NONPROD**
  - Rota padrão: 0.0.0.0/0 → NAT Gateway
  - Rota de serviço: Service Gateway (condicional)
  - Uso: Subnets privadas

#### 5️⃣ Subnets (3 total)
```
1. subnet-pub-shared-nonprod
   ├── OCID: ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaatzratallnm2ry2dufrki2vs4y4zoekleskm6nxjbnoygt3aed23q
   ├── CIDR: 10.0.1.0/24 (254 IPs disponíveis)
   ├── Tipo: Pública
   ├── Route Table: RT-PUBLIC-SHARED-NONPROD
   └── IP Público: Permitido

2. subnet-priv-shared-nonprod
   ├── OCID: ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaarqmype6bq223blqk3ql4ltph4reflyrxntu52uax7c4l5r7wf5la
   ├── CIDR: 10.0.2.0/24 (254 IPs disponíveis)
   ├── Tipo: Privada
   ├── Route Table: RT-PRIVATE-SHARED-NONPROD
   └── IP Público: Proibido

3. projeto-x (Subnet de Projeto)
   ├── OCID: ocid1.subnet.oc1.sa-saopaulo-1.aaaaaaaaxesvskkig44ljto3fk2drvxhug7o5meyzrs5o76qhayhxvoikipa
   ├── CIDR: (configurado por projeto)
   ├── Tipo: Privada
   ├── Route Table: RT-PRIVATE-SHARED-NONPROD
   └── Compartimento: Projeto X
```

#### 6️⃣ Recursos de Aplicação (Projeto X)

**VM Instance (projeto-x)**
- Tipo: Instância de computação
- Shape: VM.Standard2.1 (ou configurado)
- Availability Domain: Primeiro AD da tenancy
- Subnet: projeto-x
- Status: Em execução

**Object Storage Bucket (projeto-x)**
- Nome: bucket-projeto-x
- Storage Tier: Standard
- Namespace: Namespace da tenancy
- Compartimento: Projeto X

**IAM Policy (projeto-x)**
- Nome: policy-projeto-x
- Descrição: Política IAM para o projeto projeto-x
- Compartimento: NONPROD (root)
- Statements: Permissões configuradas para o projeto

### Organograma NONPROD

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Tenancy: Nansen Sistemas                         │
│                  (ocid1.tenancy.oc1..aaaaaaaaehlq...)               │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
                    ┌─────────────────────────┐
                    │ Compartment: NONPROD    │
                    │  (Root Level)           │
                    └─────────────────────────┘
                          │       │       │
              ┌───────────┼───────┼───────┴──────────┐
              │           │       │                  │
              ▼           ▼       ▼                  ▼
        ┌─────────┐ ┌─────────┐ ┌─────────┐  ┌──────────────┐
        │Projeto X│ │Projeto Y│ │Projeto Z│  │ IAM Policy   │
        │ (child) │ │ (child) │ │ (child) │  │ projeto-x    │
        └─────────┘ └─────────┘ └─────────┘  └──────────────┘
              │
              ▼
    ┌─────────────────────────────────────────┐
    │   SHARED-VCN-NONPROD (10.0.0.0/16)     │
    └─────────────────────────────────────────┘
              │                    │
┌─────────────┴──────┐   ┌─────────┴──────────┐
│                    │   │                    │
▼                    ▼   ▼                    ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ IGW (Public) │    │ NAT (Private)│    │ SGW (Service)│
└──────────────┘    └──────────────┘    └──────────────┘
      │                    │                    
      ▼                    ▼                    
┌──────────────┐    ┌──────────────┐             
│  RT-PUBLIC   │    │  RT-PRIVATE  │             
└──────────────┘    └──────────────┘             
      │                    │       │              
      ▼                    ▼       ▼              
┌──────────────┐    ┌──────────────┐  ┌──────────────┐
│ subnet-pub-  │    │ subnet-priv- │  │  projeto-x   │
│shared-nonprod│    │shared-nonprod│  │   (subnet)   │
│(10.0.1.0/24) │    │(10.0.2.0/24) │  │              │
└──────────────┘    └──────────────┘  └──────────────┘
      │                    │                    │
      ▼                    ▼                    ▼
 [Sem VMs]           [Sem VMs]         ┌──────────────┐
                                       │  VM Instance │
                                       │  projeto-x   │
                                       └──────────────┘
                                                │
                                                ▼
                                       ┌──────────────┐
                                       │ Object Bucket│
                                       │  projeto-x   │
                                       └──────────────┘
```

---

## 🔄 Comparativo Detalhado

### Infraestrutura de Rede

| Componente | PROD | NONPROD | Observações |
|------------|------|---------|-------------|
| **VCN** | SHARED-VCN-PROD | SHARED-VCN-NONPROD | Isolamento completo entre ambientes |
| **CIDR Block** | 10.0.0.0/16 | 10.0.0.0/16 | Mesma faixa (ambientes separados) |
| **Internet Gateway** | ✅ IGW-SHARED-PROD | ✅ IGW-SHARED-NONPROD | Configuração idêntica |
| **NAT Gateway** | ✅ NAT-SHARED-PROD | ✅ NAT-SHARED-NONPROD | Configuração idêntica |
| **Service Gateway** | ✅ SGW-SHARED-PROD | ✅ SGW-SHARED-NONPROD | Configuração idêntica |
| **Route Tables** | 2 (public + private) | 2 (public + private) | Configuração idêntica |
| **Subnets Compartilhadas** | 2 (pub + priv) | 2 (pub + priv) | Configuração idêntica |
| **Subnets de Projeto** | 0 | 1 (projeto-x) | NONPROD tem subnet dedicada |

### Recursos de Aplicação

| Recurso | PROD | NONPROD | Status |
|---------|------|---------|--------|
| **VMs** | 0 | 1 (projeto-x) | ⏳ PROD aguarda provisionamento |
| **Object Storage** | 0 | 1 bucket | ⏳ PROD aguarda provisionamento |
| **IAM Policies** | 0 | 1 policy | ⏳ PROD aguarda provisionamento |
| **Databases** | 0 | 0 | 🔜 Não implementado em nenhum ambiente |

### Compartimentos

| Nível | PROD | NONPROD | Finalidade |
|-------|------|---------|------------|
| **Root** | PROD | NONPROD | Compartimento principal do ambiente |
| **Child (Projetos)** | 0 | 3 | Compartimentos para isolar projetos |
| **Total** | 1 | 4 | NONPROD tem estrutura hierárquica |

---

## 📝 Observações Importantes

### PROD
1. ✅ **Infraestrutura de rede completa e pronta para uso**
2. ⚠️ **Nenhum recurso de aplicação provisionado ainda**
3. 🎯 **Próximo passo**: Provisionar VMs, buckets e políticas conforme necessidade
4. 🔒 **Ambiente isolado** e separado do NONPROD

### NONPROD
1. ✅ **Ambiente completo e funcional**
2. ✅ **Projeto exemplo (projeto-x) ativo com todos os componentes**
3. ✅ **Estrutura hierárquica de compartimentos implementada**
4. 🧪 **Ambiente de teste validado e pronto para novos projetos**

### Padrão de Código
- ✅ **Código Terraform sincronizado** entre PROD e NONPROD
- ✅ **Variável `environment`** permite reutilização do mesmo código
- ✅ **Lookups defensivos** implementados para compatibilidade
- ✅ **Data sources** para seleção automática de imagens e ADs

---

## 🎯 Recomendações e Próximos Passos

### Para PROD
1. **Criar primeiro projeto** seguindo o padrão testado em NONPROD:
   ```hcl
   # Em terraform_prod.tfvars
   project_subnets = {
     "projeto-novo" = {
       cidr_block  = "10.0.10.0/24"
       public      = false
       compartment = "prod"
     }
   }
   
   project_instances = {
     "projeto-novo" = {
       compartment = "prod"
       subnet      = "projeto-novo"
       shape       = "VM.Standard2.1"
     }
   }
   ```

2. **Provisionar recursos gradualmente**:
   - Fase 1: Criar compartimentos filhos se necessário
   - Fase 2: Criar subnets de projeto
   - Fase 3: Provisionar VMs
   - Fase 4: Criar buckets e policies

3. **Configurar monitoramento e alertas**

### Para NONPROD
1. ✅ **Manter como ambiente de testes**
2. 🧪 **Testar novos recursos antes de aplicar em PROD**
3. 📚 **Documentar padrões e boas práticas**

### Geral
1. **Implementar CI/CD** usando GitHub Actions (workflow já presente)
2. **Configurar backend remoto** para Terraform state (se ainda não configurado)
3. **Revisar políticas IAM** regularmente
4. **Implementar tags de custo** para rastreamento de gastos por projeto

---

## 📞 Informações de Suporte

- **Região OCI**: sa-saopaulo-1 (São Paulo, Brasil)
- **Provider Terraform**: oracle/oci v5.47.0
- **Repositórios Git**:
  - PROD: https://github.com/joubertNansen/OCIProdTherraform
  - NONPROD: https://github.com/joubertNansen/OCINonProdTherraform

---

**Última sincronização com OCI:** 18/12/2025  
**Status:** ✅ Atualizado
