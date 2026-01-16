# Recomendações de Migração AWS → OCI - NepenMultilink

## Análise de Adequação

A arquitetura da aplicação NEPENMULTILINK é **altamente compatível** com OCI, com mapeamentos diretos para a maioria dos serviços:

### ✅ Pontos Fortes para Migração:
- **Arquitetura stateless**: Ideal para cloud-native
- **Containers Docker**: Compatível com OKE
- **Java 17**: Suportado em todas as plataformas
- **Bancos relacionais e NoSQL**: Serviços Autonomous nativos
- **Microsserviços**: Perfeito para Kubernetes

### ⚠️ Pontos de Atenção:
- **RabbitMQ**: Não há serviço gerenciado nativo, manter em VM
- **TimescaleDB**: Usar PostgreSQL em Compute Instance + extensão
- **MongoDB**: Usar MongoDB em Compute Instance (mais econômico)
- **Configurações específicas**: Revisar flags JVM e otimizações

## Mudanças de Arquitetura para Otimização de Custos

### Decisão: Compute Instances vs Autonomous Databases

**Por que a mudança?**
- **Custo**: Autonomous Databases são ~40% mais caros que Compute Instances equivalentes
- **Controle**: Maior controle sobre configurações e otimizações
- **Flexibilidade**: Possibilidade de instalar extensões específicas (TimescaleDB)

**Comparação:**

| Aspecto | Autonomous DB | Compute Instance |
|---------|---------------|------------------|
| **Custo mensal** | $800 (PostgreSQL) | $600 (PostgreSQL) |
| **Gerenciamento** | Totalmente gerenciado | Self-managed |
| **Auto-scaling** | Automático | Manual/via scripts |
| **Backup** | Automático | Configurar manualmente |
| **Extensões** | Limitado | Total controle |

### Arquitetura Atualizada

```
AWS (Atual) → OCI (Nova Arquitetura)
├── RDS PostgreSQL → Compute VM + PostgreSQL + TimescaleDB
├── MongoDB Atlas → Compute VM + MongoDB
├── ElastiCache Redis → OCI Cache (mantido)
├── EC2 (Apps) → OKE Cluster
└── Amazon MQ → Compute VM + RabbitMQ
```

## Estratégia de Migração Recomendada

### Fase 1: Foundation (1-2 semanas)
1. **Provisionar infraestrutura base** com Terraform
2. **Configurar networking** (VCN, subnets, security)
3. **Criar bancos de dados** vazios
4. **Testar conectividade** entre componentes

### Fase 2: Data Migration (1 semana)
1. **Backup completo** dos dados AWS
2. **Migrar PostgreSQL**:
   ```bash
   # Export from AWS RDS
   pg_dump -h aws-rds-host -U user -d dbname > backup.sql

   # Import to OCI ADB
   psql -h oci-adb-host -U admin -d dbname < backup.sql
   ```
3. **Migrar MongoDB**:
   ```bash
   # Export from AWS
   mongodump --host aws-mongo-host --db ticketdb

   # Import to OCI AJD
   mongorestore --host oci-ajd-host --db ticketdb
   ```
4. **Migrar Redis**: Snapshot e restore

### Fase 3: Application Deployment (1 semana)
1. **Build containers** com mesmo Dockerfile
2. **Deploy no OKE**:
   - Eureka Server
   - API Gateway
   - Microsserviços (user, devices, ticket)
   - Conectores SNMP/LwM2M
3. **Configurar RabbitMQ** na VM dedicada
4. **Testes de integração**

### Fase 4: Cutover (1 dia)
1. **Testes finais** de carga
2. **Alterar DNS** para apontar para OCI LB
3. **Monitoramento 24/7** durante primeira semana
4. **Rollback plan** preparado

## Otimizações Específicas para OCI

### JVM Tuning para OCI Shapes
```bash
# Configuração atual (desenvolvimento)
-XX:+UseSerialGC
-Xss512k
-XX:MaxRAM=256m

# Recomendação para produção OCI
-XX:+UseG1GC
-Xss512k
-XX:MaxRAM=2g
-XX:+UseContainerSupport
-XX:MaxMetaspaceSize=512m
```

### Autonomous Database Otimizações
- **Auto-scaling**: Habilitado por padrão
- **Backup automático**: Configurado
- **Performance**: Monitorar e ajustar OCPUs se necessário
- **TimescaleDB**: Instalar extensão no ADB PostgreSQL

### OKE Considerations
- **Node pools**: Separar workloads se necessário
- **Resource limits**: Definir requests/limits nos pods
- **Network policies**: Implementar isolamento entre namespaces
- **Ingress controller**: Usar OCI Load Balancer integration

## Monitoramento e Alertas

### OCI Monitoring Setup
```terraform
# Exemplo de alarm para CPU alta
resource "oci_monitoring_alarm" "high_cpu" {
  compartment_id        = var.compartment_id
  display_name          = "High CPU Usage"
  metric_compartment_id = var.compartment_id
  namespace             = "oci_computeagent"
  query                 = "CpuUtilization[1m].mean() > 80"
  severity              = "CRITICAL"
}
```

### Métricas Críticas para Monitorar
- **Database**: CPU, memória, IOPS, conexões ativas
- **Application**: Response time, error rates, throughput
- **Infrastructure**: CPU/memory dos nodes OKE
- **Network**: Latência, packet loss, throughput

## Segurança na Migração

### Antes da Migração
- **Auditoria de segurança** da configuração AWS
- **Inventory** de todos os secrets e certificados
- **IAM roles** mapeamento para OCI policies

### Durante a Migração
- **VPN** ou **FastConnect** para transferência segura
- **Encryption** em trânsito (TLS 1.3)
- **Access logging** habilitado

### Após a Migração
- **Security posture review** na OCI
- **Vulnerability scanning** dos containers
- **Compliance checks** (se aplicável)

## Plano de Rollback

### Cenário de Emergência
1. **Manter AWS infrastructure** por 30 dias
2. **DNS TTL** baixo para quick switch back
3. **Database sync** bidirecional durante transição
4. **Application blue-green** deployment

### Testes de Rollback
- **Semanal**: Testes de conectividade AWS
- **Mensal**: Full rollback drill
- **Após mudanças**: Validation tests

## Timeline Completo

```
Semana 1-2: Infra OCI + Foundation
Semana 3: Data Migration
Semana 4: Application Deploy
Dia 1 Semana 5: Cutover
Semanas 5-8: Stabilization
```

## Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| Data corruption | Baixa | Alto | Multi backups, validação checksum |
| Downtime | Média | Alto | Blue-green deployment |
| Performance degradation | Média | Médio | Load testing pré-cutover |
| Security gaps | Baixa | Alto | Security assessment |

### Custos e Otimização

#### Otimização Inicial (Versão Atualizada)
- **Compute Instances**: PostgreSQL e MongoDB em VMs dedicadas ao invés de Autonomous DB
- **Redução de custos**: ~40% menos que versão com Autonomous Databases
- **Auto-scaling**: Implementado via OCI Monitoring e alertas
- **Reserved instances**: Avaliar para workloads estáveis

#### Comparação de Custos:

| Serviço | AWS (Estimado) | OCI Autonomous | OCI Compute | Economia |
|---------|----------------|----------------|-------------|----------|
| PostgreSQL | $600/mês | $800/mês | $600/mês | $200/mês |
| MongoDB | $300/mês | $400/mês | $300/mês | $100/mês |
| Redis | $150/mês | $150/mês | $150/mês | $0 |
| **Total DB** | **$1,050/mês** | **$1,350/mês** | **$1,050/mês** | **$300/mês** |

**Total Infraestrutura**: ~$1,920/mês (vs $2,220/mês com Autonomous DB)

#### Monitoramento de Custos
- **Budgets**: Alertas para controle de gastos
- **Cost analysis**: Tags para rastreamento por projeto
- **Optimization**: Ajustes baseados no uso real

## Equipe e Responsabilidades

### Pré-Migração
- **DevOps**: Terraform, infraestrutura
- **DBA**: Estratégia de migração dados
- **Dev Team**: Code adjustments para OCI

### Durante Migração
- **DevOps Lead**: Coordenação técnica
- **DBA**: Migração dados
- **QA**: Testes funcionais

### Pós-Migração
- **SRE**: Monitoramento e alertas
- **DevOps**: Otimizações e automação
- **Business**: Validation funcional

## Success Criteria

- [ ] **Performance**: >= 95% do throughput AWS
- [ ] **Availability**: 99.9% uptime no primeiro mês
- [ ] **Cost**: <= 110% do custo AWS otimizado
- [ ] **Security**: Zero vulnerabilidades críticas
- [ ] **Compliance**: Todos os requisitos atendidos

## Próximos Passos Imediatos

1. **Reunião de kickoff** com stakeholders
2. **Detailed planning** com timelines específicas
3. **Resource allocation** para equipe de migração
4. **Proof of concept** para componentes críticos
5. **Risk assessment** detalhado

---

**Data de Criação**: Janeiro 2025
**Responsável**: Joubert Gabriel
**Revisão**: v1.0