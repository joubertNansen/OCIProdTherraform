
# ====================================================================
# ARQUIVO: cost_allocation.py
# DESCRIÇÃO: Script Python que automatiza o rateio de custos compartilhados
#            entre diferentes projetos proporcionalmente ao número de usuários
# ====================================================================

# Dicionário contendo os projetos e quantos usuários cada um tem
project_users = {
    "projeto-a": 10,      # Projeto A tem 10 usuários
    "projeto-b": 5,       # Projeto B tem 5 usuários
    "projeto-c": 15       # Projeto C tem 15 usuários
}

# Custo total mensal do compartimento compartilhado (rede, armazenamento, etc)
# em Reais (R$)
shared_cost = 3000  

# Calcula o número total de usuários somando todos os projetos
# Neste caso: 10 + 5 + 15 = 30 usuários
total_users = sum(project_users.values())

# Dicionário que vai armazenar quanto cada projeto deve pagar
# Usa uma fórmula simples: (usuários do projeto / total de usuários) * custo total
allocation = {
    project: round((users / total_users) * shared_cost, 2)
    for project, users in project_users.items()
}

# Imprime o resultado do rateio de custos
# Output esperado:
# projeto-a: R$ 1000.0   (10/30 * 3000)
# projeto-b: R$ 500.0    (5/30 * 3000)
# projeto-c: R$ 1500.0   (15/30 * 3000)
for project, cost in allocation.items():
    print(f"{project}: R$ {cost}")

