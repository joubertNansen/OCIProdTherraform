
"""
Script: Automação de rateio de custos por número de usuários.

Descrição:
 - Recebe um dicionário com a quantidade de usuários por projeto.
 - Calcula a proporção de custo dividido igualmente segundo o número de
   usuários de cada projeto.
 - Imprime o valor alocado por projeto.

Uso:
 - Este é um exemplo simples, não conecta com APIs ou bancos — apenas ilustra
   a lógica de rateio.
"""

# --- DADOS DE ENTRADA ---
# Dicionário onde a chave é o nome lógico do projeto e o valor é o número de usuários
project_users = {
    "projeto-a": 10,
    "projeto-b": 5,
    "projeto-c": 15
}

# Custo total do compartimento/recurso que será rateado entre os projetos
shared_cost = 3000  # em unidade monetária (ex.: reais)


# --- PROCESSAMENTO ---
# 1) Calcula o total de usuários somando todos os projetos
total_users = sum(project_users.values())

# 2) Gera um novo dicionário 'allocation' com a alocação de custo por projeto.
#    A fórmula usada é: (usuarios_do_projeto / total_de_usuarios) * custo_compartilhado
#    round(..., 2) formata para 2 casas decimais.
allocation = {
    project: round((users / total_users) * shared_cost, 2)
    for project, users in project_users.items()
}


# --- SAÍDA ---
# Imprime a alocação por projeto em formato legível
for project, cost in allocation.items():
    print(f"{project}: R$ {cost}")
