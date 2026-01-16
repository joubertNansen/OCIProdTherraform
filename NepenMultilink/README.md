# Infraestrutura OCI - Projeto NepenMultilink

## Visão Geral

Este projeto Terraform provisiona a infraestrutura completa na Oracle Cloud Infrastructure (OCI) para a aplicação NEPENMULTILINK, migrando da AWS para OCI.

## Arquitetura da Aplicação

A aplicação NEPENMULTILINK é composta por:

- **Microsserviços**: user-service, devices-service, ticket-service, conectores SNMP/LwM2M, módulos de integração
- **Service Discovery**: Eureka
- **API Gateway**: Spring Cloud Gateway
- **Bancos de Dados**:
  - TimescaleDB (PostgreSQL): Principal para maioria dos serviços
  - MongoDB: Para ticket-service (dados não relacionais)
  - Redis: Para LwM2M Server (sessões ativas)
- **Mensageria**: RabbitMQ
- **Runtime**: Java 17, containers Docker
- **Arquitetura**: Stateless

## Mapeamento AWS → OCI

| Componente AWS | Componente OCI | Justificativa |
|---------------|----------------|---------------|
| EC2 Instances | OCI Compute VMs | Hosts para bancos e aplicações |
| RDS PostgreSQL | Autonomous Database | Gerenciado, auto-scaling |
| MongoDB Atlas | Autonomous JSON DB | Serviço nativo OCI |
| ElastiCache Redis | OCI Cache | Serviço gerenciado Redis |
| Amazon MQ | OCI Compute VM + RabbitMQ | Flexibilidade de configuração |
| ECS/EKS | Oracle Kubernetes Engine (OKE) | Orquestração de containers |
| ALB/NLB | OCI Load Balancer | Distribuição de carga |
| VPC | Virtual Cloud Network (VCN) | Rede virtual |

## Perfil de Recursos

Baseado nas medições de produção:

### Host Database (ceblmultnmsdb01)
- **CPU**: 8 núcleos (Intel Xeon Gold 6234 @ 3.30GHz)
- **Memória**: 15 GiB (uso médio 5 GiB, picos até 7.6 GiB)
- **I/O**: Alto tráfego PostgreSQL (2.12 TB leitura / 1.49 TB escrita)
- **Shape Recomendado**: VM.Standard.E4.Flex (8 OCPU, 120 GB RAM)

### Host Applications (ceblmultnmsap01)
- **CPU**: 4 núcleos (Intel Xeon Gold 6234 @ 3.30GHz)
- **Memória**: 15 GiB (uso médio 5 GiB)
- **I/O**: Baixo, principalmente logs
- **Shape Recomendado**: VM.Standard.E4.Flex (4 OCPU, 60 GB RAM)

## Componentes Provisionados

### 1. Rede (VCN)
- VCN: 10.0.0.0/16
- Subnet Pública: 10.0.1.0/24
- Subnet Privada: 10.0.2.0/24
- Internet Gateway, NAT Gateway, Service Gateway
- Security Lists configuradas

### 2. Bancos de Dados
- **PostgreSQL (TimescaleDB)**: Instância Compute dedicada com PostgreSQL + TimescaleDB
  - Shape: VM.Standard.E4.Flex (8 OCPU, 120 GB RAM)
  - Storage: 1 TB inicial
  - Configurado com otimizações para o perfil de carga
- **MongoDB**: Instância Compute dedicada com MongoDB
  - Shape: VM.Standard.E4.Flex (4 OCPU, 60 GB RAM)
  - Configurado para ticket-service
- **Redis**: OCI Cache
  - Memória: 30 GB
  - Node count: 1

### 3. Computação
- **Instância RabbitMQ**: VM.Standard.E4.Flex (4 OCPU, 60 GB RAM)
- **Instância Monitoramento**: Para ferramentas de observabilidade

### 4. Containers (OKE)
- **Cluster OKE**: Kubernetes v1.28.2
- **Node Pool**: 3 nodes VM.Standard.E4.Flex (2 OCPU, 30 GB RAM cada)
- Para deploy dos microsserviços containerizados

### 5. Load Balancing
- **Load Balancer**: Distribuição de carga para API Gateway
- **Backend Set**: Health checks HTTP
- **Listeners**: HTTP (80) e HTTPS (443)

## Pré-requisitos

1. **Conta OCI** com permissões adequadas
2. **Chaves API OCI** configuradas
3. **Terraform** v1.0+
4. **OCI CLI** instalado e configurado

## Configuração

1. **Clone o repositório** e navegue para a pasta NepenMultilink
2. **Copie o arquivo de exemplo**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
3. **Configure as variáveis** no arquivo `terraform.tfvars`:
   - tenancy_ocid, user_ocid, fingerprint
   - private_key_path
   - compartment_id
   - availability_domain
   - Senhas dos bancos
   - OCIDs das imagens

4. **Inicialize o Terraform**:
   ```bash
   terraform init
   ```

5. **Valide a configuração**:
   ```bash
   terraform validate
   ```

6. **Plano de execução**:
   ```bash
   terraform plan
   ```

7. **Aplique a infraestrutura**:
   ```bash
   terraform apply
   ```

## Ordem de Provisionamento

O Terraform provisionará os recursos na seguinte ordem:

1. **Rede (VCN, subnets, gateways)**
2. **Bancos de Dados (ADB PostgreSQL, MongoDB, Redis)**
3. **Computação (VMs para RabbitMQ e monitoramento)**
4. **OKE Cluster e Node Pool**
5. **Load Balancer**

## Considerações de Segurança

- **Security Lists**: Configuradas para permitir apenas tráfego necessário
- **Private Subnets**: Para bancos de dados e recursos internos
- **IAM**: Políticas de acesso por compartimento
- **Encryption**: Dados em trânsito e repouso criptografados

## Monitoramento e Observabilidade

- **OCI Monitoring**: Métricas de CPU, memória, rede
- **Logging**: Centralização de logs
- **Alarms**: Alertas para utilização alta de recursos

## Migração da AWS

### Passos Recomendados:

1. **Backup dos dados** atuais na AWS
2. **Provisionar infraestrutura OCI** com este Terraform
3. **Migrar bancos de dados**:
   - PostgreSQL: pg_dump/pg_restore ou AWS DMS
   - MongoDB: mongodump/mongorestore
   - Redis: Backup/restore dos dados
4. **Deploy da aplicação** no OKE
5. **Testes de carga** e validação
6. **Cutover**: Alterar DNS/traffic para OCI
7. **Decommission** recursos AWS

### Equivalências de Serviço:

| AWS Service | OCI Service | Notas |
|-------------|-------------|-------|
| EC2 | Compute VM | Shapes similares disponíveis |
| RDS | Autonomous DB | Gerenciado, auto-scaling |
| ElastiCache | OCI Cache | Redis/Memcached |
| SQS/SNS | Streaming/Notifications | Ou manter RabbitMQ |
| ECS/EKS | OKE | Kubernetes nativo |
| ALB/NLB | Load Balancer | L7/L4 load balancing |
| CloudWatch | Monitoring | Métricas e logs |
| VPC | VCN | Rede virtual |

## Custos Estimados

### Recursos Principais (Configuração Otimizada):
- **PostgreSQL Instance**: ~$800/mês (VM.Standard.E4.Flex, 8 OCPU, 120 GB RAM)
- **MongoDB Instance**: ~$400/mês (VM.Standard.E4.Flex, 4 OCPU, 60 GB RAM)
- **OKE Cluster**: ~$300/mês (3 nodes VM.Standard.E4.Flex)
- **RabbitMQ Instance**: ~$200/mês (VM.Standard.E4.Flex, 4 OCPU, 60 GB RAM)
- **Load Balancer**: ~$20/mês
- **OCI Cache**: ~$150/mês (30 GB Redis)
- **Block Storage**: ~$50/mês (dados e backups)

**Total Estimado**: ~$1,920/mês

*Redução de ~$1,150/mês em relação à versão com Autonomous Databases (~$3,070/mês)*

## Próximos Passos

1. **Deploy da aplicação** no cluster OKE
2. **Configuração do CI/CD** para pipelines automatizados
3. **Implementar backup** e disaster recovery
4. **Configurar monitoring** avançado
5. **Otimização de custos** baseada no uso real

## Suporte

Para dúvidas ou problemas:
- Consulte a documentação OCI
- Verifique os logs do Terraform
- Abra issue no repositório do projeto