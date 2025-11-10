
# Automação de rateio de custos por número de usuários
project_users = {
    "projeto-a": 10,
    "projeto-b": 5,
    "projeto-c": 15
}

shared_cost = 3000  # custo total do compartimento compartilhado

total_users = sum(project_users.values())

allocation = {
    project: round((users / total_users) * shared_cost, 2)
    for project, users in project_users.items()
}

for project, cost in allocation.items():
    print(f"{project}: R$ {cost}")
