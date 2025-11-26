# ====================================================================
# ARQUIVO: main.tf
# DESCRIÇÃO: Arquivo principal do Terraform que organiza toda a infraestrutura
#            A configuração do provedor OCI foi movida para providers.tf
# ====================================================================

# Módulo de Infraestrutura
# Agrupa toda a configuração de recursos (redes, máquinas, bancos de dados, etc.)
# Usar módulos facilita a reutilização e manutenção do código
/*
Módulo "infra" removido: evitar referência recursiva ao diretório raiz.
Os recursos existentes na raiz (vcn.tf, buckets.tf, instances.tf, etc.)
serão aplicados diretamente sem encapsular a raiz como um módulo.
*/
