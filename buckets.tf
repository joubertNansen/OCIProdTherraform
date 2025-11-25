# ====================================================================
# ARQUIVO: buckets.tf
# DESCRIÇÃO: Define os buckets de armazenamento em objeto (Object Storage)
#            Similar ao AWS S3 - serve para guardar arquivos, logs, backups, etc
# ====================================================================

# Recurso: Bucket de Armazenamento de Objetos OCI
# Cria espaços de armazenamento para arquivos na nuvem
/*
Recurso: Bucket de Object Storage (um por projeto)
 - Usa `for_each` para criar um bucket para cada entrada em `var.project_buckets`.
 - `each.key` é o nome lógico do projeto; `each.value` contém os atributos
   (compartment_id e namespace) necessários para criar o bucket.
 - Ajuste `storage_tier` conforme necessidade (Standard, Archive, etc.).
*/
resource "oci_objectstorage_bucket" "project_bucket" {
  for_each = var.project_buckets # for_each: Cria um bucket para cada projeto definido em var.project_buckets
  name           = "bucket-${each.key}" # name: Nome do bucket (ex: bucket-projeto-a-nonprod) # Será precedido por um prefixo automático para garantir unicidade global
  compartment_id = each.value.compartment_id  # compartment_id: ID do compartimento onde o bucket será criado
  namespace      = each.value.namespace  # namespace: Namespace (identificador global único do bucket) # Geralmente é o namespace da tenancy (conta)
  storage_tier   = "Standard" # storage_tier: Tipo de armazenamento # "Standard" = acesso frequente (mais rápido, mais caro) # "Archive" = acesso infrequente (mais lento, mais barato)
}
