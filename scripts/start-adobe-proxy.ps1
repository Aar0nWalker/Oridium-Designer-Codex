# Прокси между MCP-серверами и плагинами Adobe. Держать окно открытым во время работы.
$ErrorActionPreference = 'Stop'
$proxy = Join-Path (Resolve-Path "$PSScriptRoot\..").Path 'vendor\adb-mcp\adb-proxy-socket'
if (-not (Test-Path (Join-Path $proxy 'node_modules'))) {
    Write-Host "Сначала запусти установку: setup/install.ps1" -ForegroundColor Red
    exit 1
}
Write-Host "Adobe-прокси запущен. Не закрывай это окно, пока работаешь с Photoshop/Illustrator/AE/InDesign/Premiere." -ForegroundColor Green
node (Join-Path $proxy 'proxy.js')
