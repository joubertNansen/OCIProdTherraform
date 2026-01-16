## Application Organogram — OCI Terraform (PROD & NONPROD)

Este documento apresenta um organograma da aplicação/infrastrutura provisionada pelos dois repositórios `OCIProdTherraform` e `OCINonProdTherraform`. O objetivo é mostrar, de forma visual e descritiva, os componentes principais, relações entre eles e as variáveis que controlam criações opcionais.

---

## Visão Geral (one-line)

Dois repositórios Terraform gerenciam a infraestrutura de rede e recursos básicos na Oracle Cloud (OCI):

- `OCIProdTherraform` — ambiente de PRODUÇÃO (VCN 10.1.0.0/16 por padrão no repo)
- `OCINonProdTherraform` — ambiente de NÃO-PRODUÇÃO (VCN 10.2.0.0/16 por padrão no repo)

Ambos criam a mesma topologia lógica: tenancy → compartimentos → VCN compartilhada → gateways/route-tables → subnets (públicas/privadas) → recursos por projeto (VMs, buckets, DBs) — muitos blocos opcionais estão desativados por padrão e controlados por flags em `variables.tf`.

---

## Organograma (ASCII)

Tenancy (OCI)
|
+- Compartments (raiz)
   |
   +- shared-network-<env> (onde a VCN e gateways vivem)
   |  |
   |  +- VCN (e.g. SHARED-VCN-PROD / SHARED-VCN-NONPROD)
   |  |  |
   |  |  +- Internet Gateway (IGW)
   |  |  +- NAT Gateway (NAT)
   |  |  +- Service Gateway (SGW)
   |  |  +- Route Table (public) -> IGW
   |  |  +- Route Table (private) -> NAT (± SGW rule)
   |  |  +- Subnet public_shared (ex: 10.1.1.0/24 ou 10.2.1.0/24)
   |  |  +- Subnet private_shared (ex: 10.1.2.0/24 ou 10.2.2.0/24)
   |  |
   |  +- project_subnets (opcionais) -> isolam projetos específicos
   |
   +- projeto-a-<env> (compartimento do projeto)
      |
      +- Recursos por projeto (criados via for_each quando configurados):
         - Instâncias (VMs) — `oci_core_instance`
         - Buckets — `oci_objectstorage_bucket`
         - DB Systems — `oci_database_db_system`
         - IAM Policies — `oci_identity_policy`s

Legenda: `<env>` = `prod` ou `nonprod` conforme repositório correspondente.

---

## Componentes principais (descrição rápida)

- Compartimentos (`oci_identity_compartment`): organizam recursos por ambiente e projeto. A criação de compartimentos filhos está controlada por `variable "enable_child_compartments"` (padrão: false).
- VCN (`oci_core_virtual_network`): VCN compartilhada por ambiente (nome: SHARED-VCN-PROD/SHARED-VCN-NONPROD). CIDR parametrizável via `vcn_cidr` no `*.tfvars`.
- Gateways: IGW (internet), NAT (saida para internet para instâncias privadas) e SGW (acesso a serviços OCI sem passar pela internet pública). SGW routes são opcionais e controladas por `enable_service_gateway_routes` e `service_gateway_destination`.
- Route tables: `rt_public` (aponta para IGW) e `rt_private` (aponta para NAT e condicionalmente para SGW).
- Subnets: `public_shared` e `private_shared`. Subnets dedicadas por projeto podem ser ativadas via `enable_project_subnets`.
- Recursos por projeto: instâncias, buckets e bancos — todos modelados com `for_each` em variáveis (`project_instances`, `project_buckets`, `project_databases`) e por padrão estão vazios no repositório.
- IAM Policies: geradas a partir de `project_policies` quando preenchidas.

---

## Mapeamento PROD vs NONPROD (valores padrão nos tfvars entregues)

- PROD (`OCIProdTherraform`)
  - VCN CIDR: 10.1.0.0/16 (arquivo: `terraform_prod.tfvars`)
  - Subnet pública: 10.1.1.0/24
  - Subnet privada: 10.1.2.0/24

- NONPROD (`OCINonProdTherraform`)
  - VCN CIDR: 10.2.0.0/16 (arquivo: `terraform_nonprod.tfvars`)
  - Subnet pública: 10.2.1.0/24
  - Subnet privada: 10.2.2.0/24

Observação: esses valores aparecem nos arquivos `terraform_*.tfvars` e em `variables.tf` como defaults. Verifique os tfvars antes de aplicar.

---

## Variáveis de controle importantes

- `enable_child_compartments` (bool) — habilita criação de compartimentos filhos (uso: Phase 2). Default: false.
- `enable_project_subnets` (bool) — habilita criação de subnets específicas por projeto. Default: false.
- `enable_service_gateway_routes` (bool) — habilita rota do Service Gateway no route table privado. Default: false.
- `service_gateway_destination` (string) — destino da rota do SGW (somente se a flag acima for true).

Use essas flags com cuidado: elas protegem contra erros de permissão e destinos inválidos.

---

## Pontos de atenção / recomendações

1. Separar chaves API entre ambientes (não reusar a mesma chave para PROD e NONPROD). Colocar caminhos de chaves e `*.tfvars` sensíveis no `.gitignore`.
2. Migrar o backend do Terraform para um backend remoto (OCI Object Storage ou Terraform Cloud) para evitar estado local e problemas de concorrência.
3. Ativar `enable_child_compartments` somente após obter permissões de Identity Admin — criar compartimentos filhos requer privilégio específico.
4. Validar `service_gateway_destination` antes de ativar SGW routes (valor vazio evita criação por padrão).
5. Recomendo preencher e testar `project_policies` e `project_subnets` primeiro em NONPROD.

---

## Arquivos úteis (onde olhar no repositório)

- `variables.tf` — lista de todas as variáveis e flags.
- `compartments.tf` — lógica de criação de compartments (root_level e child_level guardados por flag).
- `vcn.tf` — VCN, gateways, route tables e subnets.
- `instances.tf`, `buckets.tf`, `databases.tf` — recursos por projeto (geralmente comentados/inativos até serem configurados nas variáveis).
- `iam_policies.tf` — criação de policies a partir de `project_policies`.
- `terraform_prod.tfvars` / `terraform_nonprod.tfvars` — valores por ambiente.

---

## Próximos passos sugeridos (curto prazo)

1. Revisar `terraform_nonprod.tfvars` e `terraform_prod.tfvars` para garantir caminhos de chave e OCIDs corretos.
2. Habilitar e testar `project_policies` e `project_subnets` em NONPROD.
3. Solicitar permissão Identity Admin se quiser ativar `enable_child_compartments` para criar compartments filhos via Terraform.
4. Configurar backend remoto para o state.

---

Se quiser, eu já posso:

- Gerar um diagrama em Mermaid (para visualizar no GitHub) e commitar ao mesmo arquivo.
- Preencher exemplos de `project_policies` e `project_subnets` baseados no que espera criar.

Diga qual das opções prefere que eu faça a seguir.
