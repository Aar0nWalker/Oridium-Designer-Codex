#!/usr/bin/env bash
# Прокси между MCP-серверами и плагинами Adobe. Держать окно открытым во время работы.
set -euo pipefail
PROXY="$(cd "$(dirname "$0")/.." && pwd)/vendor/adb-mcp/adb-proxy-socket"
[ -d "$PROXY/node_modules" ] || { echo "Сначала запусти установку: bash setup/install.sh"; exit 1; }
echo "Adobe-прокси запущен. Не закрывай это окно, пока работаешь с Photoshop/Illustrator/AE/InDesign/Premiere."
exec node "$PROXY/proxy.js"
