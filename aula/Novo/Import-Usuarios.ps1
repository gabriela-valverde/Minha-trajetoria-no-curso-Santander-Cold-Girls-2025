# Verifica se o arquivo CSV foi fornecido como argumento
if (-not $args[0]) {
    Write-Host "Por favor, forneça o arquivo CSV como argumento."
    exit
}

# Armazena o nome do arquivo de entrada
$InputFile = $args[0]

# Verifica se o arquivo de entrada existe
if (-not (Test-Path $InputFile)) {
    Write-Host "$InputFile arquivo não encontrado."
    exit
}

# Importa o arquivo CSV. O PowerShell cuida da conversão de formato de linha automaticamente.
$Users = Import-Csv -Path $InputFile -Delimiter ';' -Header Usuario, Grupo, Senha

# Loop para ler cada linha do arquivo CSV e processar as informações
foreach ($User in $Users) {
    
    # Armazena os dados do usuário em variáveis
    $Usuario = $User.Usuario
    $Grupo = $User.Grupo
    $Senha = $User.Senha

    # Exibe a informação do usuário que está sendo processado
    Write-Host "Processando usuário: $Usuario"

    # Cria o usuário no IAM
    aws iam create-user --user-name "$Usuario"
    
    # Define a senha e solicita a redefinição no próximo login
    aws iam create-login-profile --password-reset-required --user-name "$Usuario" --password "$Senha"
    
    # Adiciona o usuário ao grupo especificado
    aws iam add-user-to-group --group-name "$Grupo" --user-name "$Usuario"

    Write-Host "Usuário $Usuario importado com sucesso."
}

Write-Host "Todos os usuários foram importados."