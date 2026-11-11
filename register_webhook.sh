#!/usr/bin/env bash
# Registers the n8n Production Webhook URL with Unipile v2 for real-time LinkedIn message events

UNIPILE_API_KEY="YOUR_UNIPILE_API_KEY"
UNIPILE_ACCOUNT_ID="YOUR_UNIPILE_ACCOUNT_ID"
N8N_WEBHOOK_URL="https://your-n8n-instance.app.n8n.cloud/webhook/YOUR-WEBHOOK-UUID"

curl --request POST \
  --url https://api.unipile.com/v2/webhooks \
  --header "X-API-KEY: ${UNIPILE_API_KEY}" \
  --header "accept: application/json" \
  --header "content-type: application/json" \
  --data "{
    \"request_url\": \"${N8N_WEBHOOK_URL}\",
    \"events\": [\"message.new\"],
    \"account_ids\": [\"${UNIPILE_ACCOUNT_ID}\"]
  }"