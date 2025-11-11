#!/bin/bash

# --- Script de Automação Git ---

# 1. Adiciona todos os arquivos modificados/novos
git add .

# 2. Verifica se o commit é necessário (se há alterações staged)
if git diff --cached --quiet; then
    echo "Nenhuma alteração a ser commitada. Saindo."
else
    # 3. Solicita a mensagem de commit
    echo "Por favor, digite a mensagem de commit:"
    read commit_message

    # 4. Comita as alterações
    git commit -m "$commit_message"

    # 5. Envia para o repositório remoto (assumindo o 'origin' e a branch 'main' ou 'master')
    # Ajuste 'main' para o nome da sua branch principal se for diferente
    git push origin main
    
    if [ $? -eq 0 ]; then
        echo "✅ Sucesso! Os arquivos foram enviados para o GitHub."
    else
        echo "❌ Falha no envio. Verifique se você está autenticado e se a branch está correta."
    fi
fi