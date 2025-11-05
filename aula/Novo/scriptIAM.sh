#!/bin/bash

# Verifica se o argumento de entrada foi fornecido
if [ -z "$1" ]; then
    echo "Por favor, forneça o arquivo CSV como argumento."
    exit 1
fi

# Armazena o nome do arquivo de entrada
INPUT="$1"

# Verifica se o arquivo de entrada existe
if [ ! -f "$INPUT" ]; then
    echo "$INPUT arquivo não encontrado"
    exit 1
fi

# Verifica se o utilitário dos2unix está instalado
command -v dos2unix >/dev/null || { echo "utilitário dos2unix não encontrado. Por favor, instale dos2unix antes de executar o script."; exit 1; }

# Converte o arquivo CSV para o formato Unix para garantir compatibilidade
dos2unix "$INPUT"

# Loop para ler cada linha do arquivo CSV e processar as informações
while IFS= read -r line || [ -n "$line" ]; do
    
	# Separa as informações usando o delimitador ';' e atribui a variáveis
    usuario=$(echo "$line" | cut -d';' -f1)
    grupo=$(echo "$line" | cut -d';' -f2)
    senha=$(echo "$line" | cut -d';' -f3)

    # Cria um usuário no IAM
    aws iam create-user --user-name "$usuario"
    # Define uma senha e solicita a redefinição da senha no próximo login
    aws iam create-login-profile --password-reset-required --user-name "$usuario" --password "$senha"
    # Adiciona o usuário ao grupo especificado
    aws iam add-user-to-group --group-name "$grupo" --user-name "$usuario"
done < "$INPUT"

echo "Usuários importados com sucesso."
