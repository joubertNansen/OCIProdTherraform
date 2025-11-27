# Phase 2 & 3 Checklist (PROD)

Objetivo: passos práticos e responsáveis para implementar Compartimentos Filhos (Phase 2) e Políticas IAM (Phase 3) em produção.

1. Pré-requisitos
   - Verificar se há autorização administrativa (Identity Admin) para a conta/usuário que executará as ações.
   - Backup do estado Terraform atual e confirmar localização do backend remoto.
   - Revisar `terraform_prod.tfvars` e garantir que valores sensíveis não estejam no repo.

2. Phase 2 — Compartimentos Filhos
   - Definir quais compartimentos filhos criar (map em `var.compartments` com `parent_ocid` apropriado).
   - Habilitar a flag `enable_child_compartments = true` em um arquivo de tfvars seguro (não commitar em repo público).
   - Validar localmente: `terraform init -backend-config="..."` e `terraform plan -var-file="secrets.tfvars"`.
   - Revisar plano com time de segurança/ownership (quem terá acesso aos novos compartimentos?).
   - Aplicar em janela controlada: `terraform apply -var-file="secrets.tfvars"`.
   - Verificar no Console OCI se os compartimentos foram criados com os parent_ocid corretos.

3. Phase 3 — Políticas IAM
   - Modelar statements mínimos para cada grupo/role em `var.project_policies`.
   - Revisar e validar statements (evitar `manage all-resources` quando possível).
   - Criar política em modo plan e revisar: `terraform plan -var-file="secrets.tfvars"`.
   - Coordenar com equipe de IAM/Segurança para revisão antes do apply.
   - Aplicar e validar logs/audit no OCI.

4. Rollback e contingência
   - Se o apply criar recursos incorretos, usar `terraform destroy -target=<resource>` ou reverter via Git para a versão anterior e aplicar plano de correção.
   - Garantir que o estado tfstate esteja seguro e que snapshots do state sejam mantidos antes de alterações críticas.

5. Pós-implantação
   - Atualizar `CHANGELOG.md` com resumo da ação, hashes de commit e responsável.
   - Atualizar documentação (README/docs) com novos compartimentos e políticas.
   - Comunique time e registre owners para os novos compartimentos.

Responsáveis sugeridos:
- Infra/DevOps (execução do Terraform)
- Security/IAM (revisão de policies)
- Arquiteto de Rede (revisão de desenho de compartimentos)
