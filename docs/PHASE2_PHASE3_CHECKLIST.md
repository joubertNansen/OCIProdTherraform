# Phase 2 & 3 Checklist (NONPROD)

Objetivo: passos práticos e responsáveis para implementar Compartimentos Filhos (Phase 2) e Políticas IAM (Phase 3) em nonprod de forma segura.

1. Pré-requisitos
   - Confirmar que nonprod é um ambiente identificável e que alterações não impactam prod.
   - Backup do estado Terraform atual.

2. Phase 2 — Compartimentos Filhos
   - Definir `var.compartments` e `parent_ocid` corretos.
   - Habilitar `enable_child_compartments = true` em arquivo de tfvars local (não commitar).
   - Rodar: `terraform init -backend-config="..."` e `terraform plan -var-file="secrets-nonprod.tfvars"`.
   - Revisar e aplicar: `terraform apply -var-file="secrets-nonprod.tfvars"`.

3. Phase 3 — Políticas IAM
   - Modelar políticas em `var.project_policies`, revisar com Security.
   - Testar em nonprod antes de aplicar em prod.

4. Rollback e contingência
   - Manter snapshots do state e ter plano de reversão.

5. Pós-implantação
   - Atualizar `CHANGELOG-NONPROD.md` e `README.md` com observações.

Responsáveis sugeridos: Infra (execução), Security (revisão)
