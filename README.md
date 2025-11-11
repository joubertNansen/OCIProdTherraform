## OCIProdTherraform

Repositório com módulo Terraform que cria infra básica na Oracle Cloud
Infrastructure (OCI). Contém recursos parametrizados para:

- Compartimentos (compartments)
- VCN e subnets
- Instâncias (VMs)
- Buckets de Object Storage
- Bancos de dados (DB systems)
- Políticas IAM por projeto

Arquivos principais:
- `main.tf` - provider e invocação do módulo
- `variables.tf` - declarações de variáveis
- `buckets.tf`, `instances.tf`, `databases.tf`, `iam_policies.tf` - recursos
- `terraform_prod.tfvars` - exemplo de valores para ambiente de produção
- `cost_allocation.py` - script auxiliar demonstrativo (rateio de custos)
- `push.sh` / `push.ps1` - scripts para facilitar commits/push

Leia os comentários nos arquivos `.tf` e no `terraform_prod.tfvars` para
entender como parametrizar o deploy.

## Como executar o deploy (exemplo rápido)

Aviso: este repositório contém exemplos com valores de produção fictícios.
Não rode `terraform apply` em um ambiente real sem antes revisar as variáveis
e confirmar que você tem autorização para criar recursos na conta OCI.

1. Configure as credenciais do provider OCI

- Opção 1 — usar `terraform_prod.tfvars` (já existe no repositório):
	- Edite `terraform_prod.tfvars` e preencha os campos `tenancy_ocid`, `user_ocid`,
		`fingerprint`, `private_key_path` e `region` com os valores corretos.

- Opção 2 — usar variáveis de ambiente ou mecanismo de secrets (recomendado
	em CI): defina as variáveis necessárias e prefira não commitar valores sensíveis.

2. Inicializar o Terraform

No Windows PowerShell (na pasta do repositório):

```powershell
terraform init
```

3. Validar e planejar

```powershell
terraform validate
terraform plan -var-file="terraform_prod.tfvars" -out=tfplan
```

4. Aplicar o plano (revise o `tfplan` antes de aplicar)

```powershell
terraform apply "tfplan"
```

5. Pós-deploy

- Verifique no Console OCI os recursos criados (VCN, subnets, instâncias,
	buckets e DB systems) e confirme que estão nos compartments corretos.

## Uso dos scripts de commit/push

- `push.sh` — script Bash (Linux/macOS)
- `push.ps1` — script PowerShell (Windows). Exemplo de uso no PowerShell:

```powershell
.\push.ps1
```

## Notas de segurança e boas práticas

- Nunca armazene chaves privadas diretamente no repositório. Mova chaves para
	`%USERPROFILE%\.ssh` e adicione `key`/padrões ao `.gitignore` (já configurado).
- Senhas e secrets (ex.: `admin_password` em `terraform_prod.tfvars`) devem ser
	gerenciadas via mecanismo seguro (Vault, OCI Vault, variables de pipeline),
	e não commitadas em texto claro no repo.
- Considere usar SSH com `ssh-agent` ou Git Credential Manager para autenticação
	com o Git. No Windows, inicie e habilite o serviço `ssh-agent` se usar chaves SSH.

## Restauração / limpeza

- Para desfazer: rode `terraform destroy -var-file="terraform_prod.tfvars"` —
	revise antes de executar pois irá remover recursos.

## Perguntas frequentes (rápidas)

- Posso rodar isso localmente? Sim, se tiver acesso e permissões na tenancy OCI.
- Como evitar custos? Teste primeiro em uma tenancy de desenvolvimento e
	remova recursos após o teste (`terraform destroy`).

---

Se quiser, eu posso gerar um script de CI (GitHub Actions) que automatize o
plan/apply em um fluxo seguro com secrets — quer que eu faça isso?
