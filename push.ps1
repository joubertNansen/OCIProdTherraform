<#
  Script de push para PowerShell (Windows).
  - Não adiciona chaves privadas (assume que estão no .gitignore)
  - Pede mensagem de commit interativamente
  - Tenta dar push para origin/main
#>

# Adiciona todos os arquivos (respeita .gitignore)
git add .

# Verifica se há alterações staged
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Output "Nenhuma alteração a ser commitada. Saindo."
    exit 0
}

# Pede mensagem de commit
$commit_message = Read-Host "Por favor, digite a mensagem de commit"
if ([string]::IsNullOrWhiteSpace($commit_message)) {
    Write-Output "Mensagem de commit vazia. Saindo."
    exit 1
}

# Faz o commit
git commit -m "$commit_message"
if ($LASTEXITCODE -ne 0) {
    Write-Output "Falha no commit. Verifique mensagens acima."
    exit 1
}

# Faz push (assume 'origin' e branch 'main')
git push origin main
if ($LASTEXITCODE -eq 0) {
    Write-Output "✅ Sucesso! Os arquivos foram enviados para o remoto."
} else {
    Write-Output "❌ Falha no envio. Verifique autenticação (SSH key) ou o remote."
}
