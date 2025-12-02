```python
"""
Arquivo: cost_allocation.py
Propósito: exemplo simples de rateio de custos por número de usuários entre projetos.

Comentários em português explicando cada parte do código.
"""

# --- DADOS DE ENTRADA ---
# Dicionário onde a chave é o nome do projeto e o valor é o número de usuários
project_users = {
    "projeto-a": 10,
    "projeto-b": 5,
    "projeto-c": 15
}

# Custo total compartilhado que será rateado entre os projetos
shared_cost = 3000  # custo total do compartimento compartilhado

# --- PROCESSAMENTO ---
# Soma do total de usuários para calcular a proporção de cada projeto
total_users = sum(project_users.values())

# Cria um novo dicionário 'allocation' onde para cada projeto calculamos
# (usuarios_do_projeto / total_de_usuarios) * custo_compartilhado
# round(..., 2) deixa o valor com duas casas decimais
allocation = {
    project: round((users / total_users) * shared_cost, 2)
    for project, users in project_users.items()
}

# --- SAÍDA ---
# Imprime o valor alocado para cada projeto em formato legível
for project, cost in allocation.items():
    print(f"{project}: R$ {cost}")
```