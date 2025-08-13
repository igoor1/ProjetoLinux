#!/bin/bash

DISCORD_WEBHOOK_URL="SUA URL AQUI" # Coloque aqui seu link do WebHook.

LOG_FILE="/var/log/monitoramento.log"

enviar_notificacao(){
    local message="$1"

    local json_payload
    json_payload=$(printf '{
    "username": "Monitor de Site", "embeds": [{"title": "Relatório Nginx", "description": "%s", "color": 15158332, "footer": {"text": "Verificado em: %s"}}]}' "$message" "$(date '+%d/%m/%Y %H:%M:%S')")

    curl -H "Content-Type: application/json" -d "$json_payload" "$DISCORD_WEBHOOK_URL"
}

STATUS=$(curl -s -o /dev/null -w "%{http_code}" 192.168.1.1)  # Coloque aqui seu endereço IP.

if [ "$STATUS" == 200 ]; then
    SITE_STATUS="✅ O site está ONLINE!"
    echo "$(date '+%d/%m/%Y %H:%M:%S') | $SITE_STATUS" >> "$LOG_FILE"
else 
    SITE_STATUS="⛔ O site está OFFLINE!"
    echo "$(date '+%d/%m/%Y %H:%M:%S') | $SITE_STATUS" >> "$LOG_FILE"
    enviar_notificacao "$SITE_STATUS" "error"

    service nginx restart # Comando para reiniciar o Nginx.
fi