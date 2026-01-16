# Checklist de Treinamento OCI - Equipe Nansen

## Pré-Treinamento

### Ambiente de Desenvolvimento
- [*] Instalar OCI CLI
- [*] Instalar Terraform v1.14+
- [*] Configurar chaves SSH
- [*] Gerar chaves API OCI
- [*] Configurar OCI CLI profile
- [*] Testar autenticação OCI
- [*] Clonar repositório do projeto
- [*] Configurar variáveis de ambiente

### Conhecimento Prévio
- [ ] Conceitos básicos de cloud computing
- [ ] Noções de redes (VCN, subnets, security lists)
- [ ] Conceitos de infraestrutura como código
- [ ] Comandos básicos Linux/Unix
- [ ] Version control com Git

## Módulo 1: Fundamentos OCI

### Teoria
- [ ] Entender arquitetura OCI (regiões, ADs, fault domains)
- [ ] Compreender compartments e IAM
- [ ] Conhecer principais serviços OCI
- [ ] Entender cobrança e custos

### Prática
- [ ] Navegar OCI Console
- [ ] Criar compartment de teste
- [ ] Explorar regiões e availability domains
- [ ] Verificar limites de serviço

## Módulo 2: Terraform Basics

### Teoria
- [ ] Sintaxe HCL (HashiCorp Configuration Language)
- [ ] Conceitos: providers, resources, data sources
- [ ] State management
- [ ] Variables e outputs

### Prática
- [ ] `terraform init`
- [ ] `terraform validate`
- [ ] `terraform plan`
- [ ] `terraform apply`
- [ ] `terraform destroy`

## Módulo 3: Networking (VCN)

### Teoria
- [ ] Virtual Cloud Networks
- [ ] Subnets (públicas vs privadas)
- [ ] Security Lists e Network Security Groups
- [ ] Gateways (Internet, NAT, Service)
- [ ] Route Tables

### Prática - Exercício 1
- [ ] Criar VCN com CIDR 10.0.0.0/16
- [ ] Criar subnet pública (10.0.1.0/24)
- [ ] Criar subnet privada (10.0.2.0/24)
- [ ] Configurar Internet Gateway
- [ ] Configurar NAT Gateway
- [ ] Configurar Route Tables
- [ ] Configurar Security Lists
- [ ] Validar configuração

## Módulo 4: Compute (Instâncias)

### Teoria
- [ ] Shapes e tipos de instância
- [ ] Images (Ubuntu, Oracle Linux, Windows)
- [ ] Boot volumes e block volumes
- [ ] VNICs e IPs públicos/privados
- [ ] Metadata e cloud-init

### Prática - Exercício 2
- [ ] Provisionar instância Ubuntu 22.04
- [ ] Configurar shape VM.Standard.E4.Flex
- [ ] Atribuir IP público
- [ ] Configurar chave SSH
- [ ] Instalar nginx via cloud-init
- [ ] Testar acesso SSH
- [ ] Verificar serviço web

## Módulo 5: Load Balancing

### Teoria
- [ ] Load Balancers vs Network Load Balancers
- [ ] Backend sets e backends
- [ ] Health checks
- [ ] Listeners e regras

### Prática - Exercício 3
- [ ] Criar Load Balancer
- [ ] Configurar backend set
- [ ] Adicionar instâncias como backends
- [ ] Configurar health check HTTP
- [ ] Criar listener na porta 80
- [ ] Testar distribuição de carga

## Módulo 6: Database

### Teoria
- [ ] Autonomous Database vs DB Systems
- [ ] Workloads (OLTP, DW, JSON)
- [ ] Licensing models
- [ ] Backup e recovery

### Prática - Exercício 4
- [ ] Criar Autonomous Database
- [ ] Configurar workload OLTP
- [ ] Definir credenciais admin
- [ ] Verificar connection strings
- [ ] Conectar via SQL Developer (opcional)
- [ ] Executar queries básicas

## Módulo 7: Storage

### Teoria
- [ ] Object Storage (buckets, objects)
- [ ] Block Storage (volumes, backups)
- [ ] File Storage
- [ ] Storage tiers (Standard, Archive)

### Prática - Exercício 5
- [ ] Criar bucket Object Storage
- [ ] Upload de arquivos via OCI CLI
- [ ] Configurar versioning
- [ ] Criar pre-authenticated requests
- [ ] Testar acesso público (se aplicável)

## Módulo 8: Identity & Access Management

### Teoria
- [ ] Users, Groups e Dynamic Groups
- [ ] Policies e statements
- [ ] Compartments hierarchy
- [ ] Principais permissões

### Prática - Exercício 6
- [ ] Criar compartments (dev, prod)
- [ ] Criar grupos (developers, admins)
- [ ] Criar políticas de acesso
- [ ] Testar permissões
- [ ] Validar isolamento de recursos

## Módulo 9: Kubernetes (OKE)

### Teoria
- [ ] Container orchestration
- [ ] Clusters, node pools
- [ ] Deployments, services, ingress
- [ ] kubectl basics

### Prática - Exercício 7
- [ ] Criar cluster OKE
- [ ] Configurar node pool
- [ ] Instalar kubectl
- [ ] Configurar kubeconfig
- [ ] Deploy aplicação nginx
- [ ] Expor via LoadBalancer
- [ ] Testar acesso

## Módulo 10: Monitoramento e Troubleshooting

### Teoria
- [ ] OCI Monitoring e Logging
- [ ] Cloud Guard
- [ ] Alarms e notifications
- [ ] Debugging Terraform

### Prática
- [ ] Configurar monitoring básico
- [ ] Criar alarmes simples
- [ ] Verificar logs de instância
- [ ] Praticar troubleshooting comum

## Pós-Treinamento

### Avaliação
- [ ] Quiz teórico (múltipla escolha)
- [ ] Exercício prático completo
- [ ] Apresentação de solução

### Certificação
- [ ] OCI Architect Associate preparation
- [ ] Terraform Associate certification
- [ ] Próximos passos de carreira

## Responsabilidades da Equipe

### Durante o Treinamento
- [ ] Participar ativamente de todas as sessões
- [ ] Completar exercícios práticos
- [ ] Documentar dúvidas e soluções
- [ ] Compartilhar conhecimento com colegas

### Após o Treinamento
- [ ] Manter ambiente de laboratório
- [ ] Praticar regularmente
- [ ] Contribuir para documentação
- [ ] Apoiar novos membros da equipe

## Recursos Adicionais

### Documentação
- [ ] OCI Documentation completa
- [ ] Terraform OCI Provider docs
- [ ] OCI CLI reference

### Comunidades
- [ ] OCI Community Forums
- [ ] Terraform Community
- [ ] Stack Overflow

### Hands-on Labs
- [ ] OCI LiveLabs
- [ ] Terraform Learn
- [ ] GitHub examples

## Métricas de Sucesso

### Individuais
- [ ] Completar todos os exercícios
- [ ] Pontuação > 80% no quiz
- [ ] Apresentar solução funcional

### Coletivas
- [ ] Todos os membros concluirem treinamento
- [ ] Ambiente de laboratório funcional
- [ ] Documentação atualizada
- [ ] Conhecimento compartilhado

## Suporte e Mentoria

### Durante o Treinamento
- Instrutor disponível para dúvidas
- Sessões de esclarecimento
- Pair programming
- Grupos de estudo

### Após o Treinamento
- Canal dedicado no Slack/Teams
- Sessões de mentoria mensal
- Code reviews
- Projetos práticos

---

**Data de Início:** __________
**Data de Conclusão:** __________
**Instrutor:** Joubert Gabriel
**Equipe:** Nansen Infrastructure Team