#!/bin/bash

DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1403429777641181275/ySeVG4vJTrCdVvc9Li4cDLeVcMt4eQMCcRDn80GtMI6GPDcYYUjeXN2Y3xPZ8QrC4MpB"

LOG_FILE="/var/log/monitoramento.log"

enviar_notificacao(){
    local message="$1"

    local json_payload
    json_payload=$(printf '{
    "username": "Monitor de Site", "embeds": [{"title": "Relatório Nginx", "description": "%s", "color": 15158332, "footer": {"text": "Verificado em: %s"}}]}' "$message" "$(date '+%d/%m/%Y %H:%M:%S')")

    curl -H "Content-Type: application/json" -d "$json_payload" "$DISCORD_WEBHOOK_URL"
}

STATUS=$(curl -s -o /dev/null -w "%{http_code}" 192.168.1.12)

if [ "$STATUS" -eq 200 ]; then
    SITE_STATUS="✅ O site está ONLINE!"
    echo "$(date '+%d/%m/%Y %H:%M:%S') | $SITE_STATUS" >> "$LOG_FILE"
else 
    SITE_STATUS="⛔ O site está OFFLINE!"
    echo "$(date '+%d/%m/%Y %H:%M:%S') | $SITE_STATUS" >> "$LOG_FILE"
    enviar_notificacao "$SITE_STATUS" "error"

    service nginx restart
fi