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
