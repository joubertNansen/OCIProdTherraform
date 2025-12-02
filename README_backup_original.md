# OCINonProdTerraform 🚀

Infraestrutura como Código (IaC) para provisionar um ambiente **não-produção** completo na **Oracle Cloud Infrastructure (OCI)** usando Terraform.

## 📋 Índice

- [O que é esta aplicação?](#o-que-é-esta-aplicação)
- [Arquitetura](#arquitetura)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Configuração](#configuração)
- [Uso](#uso)
- [Estrutura de Arquivos](#estrutura-de-arquivos)
- [Variáveis Disponíveis](#variáveis-disponíveis)
- [Segurança](#segurança)
- [Troubleshooting](#troubleshooting)

---

## O que é esta aplicação?

Esta aplicação Terraform automatiza a criação e gerenciamento de recursos na Oracle Cloud Infrastructure (OCI), incluindo:

✅ **Rede Virtual (VCN)** com sub-redes públicas e privadas  
✅ **Máquinas Virtuais (Instâncias)** para executar aplicações  
✅ **Banco de Dados** (Oracle Database) em sub-rede privada  
✅ **Armazenamento em Objeto** (Buckets) para arquivos e backups  
✅ **Políticas de Acesso (IAM)** para controlar permissões  
✅ **Script de Rateio de Custos** para alocar custos compartilhados entre projetos  

**Ambiente:** Não-Produção (desenvolvimento, testes)  
**Região Padrão:** São Paulo (`sa-saopaulo-1`)  
**Provedor:** Oracle Cloud Infrastructure (OCI)
