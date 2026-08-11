# Oridium Designer Codex — установка (Windows)
# Запуск: powershell -ExecutionPolicy Bypass -File setup/install.ps1
$ErrorActionPreference = 'Stop'

$repo = (Resolve-Path "$PSScriptRoot\..").Path
$repoSlash = $repo -replace '\\', '/'
Write-Host "== Oridium Designer Codex: установка в $repo" -ForegroundColor Cyan

function Need($cmd, $hint) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Host "ОШИБКА: не найден '$cmd'. $hint" -ForegroundColor Red
        exit 1
    }
}
Need git  "Установи Git: https://git-scm.com/downloads (агент: winget install Git.Git, затем новое окно и перезапуск установки)"
Need node "Установи Node.js LTS: https://nodejs.org/ (агент: winget install OpenJS.NodeJS.LTS, затем новое окно и перезапуск установки)"
Need npm  "Идёт вместе с Node.js: https://nodejs.org/"

# uv — менеджер, запускающий python MCP-серверы
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "-- Ставлю uv (astral.sh/uv)..."
    Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
    $env:Path = "$env:USERPROFILE\.local\bin;$env:Path"
    Need uv "Установка uv не удалась. Поставь вручную: https://docs.astral.sh/uv/"
}

# adb-mcp — MCP-серверы Adobe
$adb = Join-Path $repo 'vendor\adb-mcp'
if (Test-Path (Join-Path $adb '.git')) {
    Write-Host "-- Обновляю adb-mcp..."
    git -C $adb pull --ff-only
} else {
    Write-Host "-- Скачиваю adb-mcp..."
    git clone https://github.com/mikechambers/adb-mcp $adb
}

Write-Host "-- Ставлю зависимости прокси Adobe..."
Push-Location (Join-Path $adb 'adb-proxy-socket')
npm install --no-fund --no-audit
Pop-Location

# Аддон Blender
$blenderAddon = Join-Path $repo 'tools\blender\addon.py'
if (-not (Test-Path -LiteralPath $blenderAddon -PathType Leaf)) {
    throw 'В репозитории нет tools\blender\addon.py'
}
Write-Host "-- Аддон Blender уже включён в репозиторий."

# Прописываем MCP-серверы в ~/.codex/config.toml (блок между маркерами)
$template = [IO.File]::ReadAllText((Join-Path $repo 'codex\config.toml.template'), [Text.Encoding]::UTF8)
$block = ($template -replace '\{\{REPO_DIR\}\}', $repoSlash).TrimEnd()
$cfgDir = Join-Path $env:USERPROFILE '.codex'
New-Item -ItemType Directory -Force $cfgDir | Out-Null
$cfgPath = Join-Path $cfgDir 'config.toml'
$begin = '# >>> oridium-designer-codex >>>'
$end = '# <<< oridium-designer-codex <<<'
$cur = if (Test-Path $cfgPath) { [IO.File]::ReadAllText($cfgPath, [Text.Encoding]::UTF8) } else { '' }
if ($cur -match [regex]::Escape($begin)) {
    $pattern = '(?s)' + [regex]::Escape($begin) + '.*?' + [regex]::Escape($end)
    $cur = [regex]::Replace($cur, $pattern, $block)
} else {
    $cur = ($cur.TrimEnd() + "`n`n" + $block + "`n").TrimStart()
}
# без BOM: строгий TOML-парсер Codex спотыкается о BOM
[IO.File]::WriteAllText($cfgPath, $cur, (New-Object Text.UTF8Encoding $false))
Write-Host "-- MCP-серверы прописаны в $cfgPath"

Write-Host ""
Write-Host "== Готово. Осталось по одному разу настроить программы — docs/SETUP.md:" -ForegroundColor Green
Write-Host "   Figma:   Figma Desktop -> Dev Mode -> Enable MCP server"
Write-Host "   Blender: установить аддон tools/blender/addon.py -> Connect"
Write-Host "   Adobe:   UXP-плагины (PS/PR/ID) + CEP-расширения (AE/AI), см. docs/SETUP.md"
Write-Host "   Прокси Adobe перед работой: scripts/start-adobe-proxy.ps1"
Write-Host "   Затем перезапусти VS Code / Codex."
