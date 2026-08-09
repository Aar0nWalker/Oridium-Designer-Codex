#!/usr/bin/env bash
# Oridium Designer Codex — установка (macOS / Linux)
# Запуск: bash setup/install.sh
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
echo "== Oridium Designer Codex: установка в $REPO"

need() { command -v "$1" >/dev/null 2>&1 || { echo "ОШИБКА: не найден '$1'. $2"; exit 1; }; }
need git  "Установи Git: https://git-scm.com/downloads (агент: на macOS xcode-select --install или brew install git, затем перезапусти установку)"
need node "Установи Node.js LTS: https://nodejs.org/ (агент: можешь поставить сам без прав администратора через nvm, затем перезапусти установку)"
need npm  "Идёт вместе с Node.js"

if ! command -v uv >/dev/null 2>&1; then
  echo "-- Ставлю uv (astral.sh/uv)..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
  need uv "Установка uv не удалась. Поставь вручную: https://docs.astral.sh/uv/"
fi

ADB="$REPO/vendor/adb-mcp"
if [ -d "$ADB/.git" ]; then
  echo "-- Обновляю adb-mcp..."
  git -C "$ADB" pull --ff-only
else
  echo "-- Скачиваю adb-mcp..."
  git clone https://github.com/mikechambers/adb-mcp "$ADB"
fi

echo "-- Ставлю зависимости прокси Adobe..."
(cd "$ADB/adb-proxy-socket" && npm install --no-fund --no-audit)

mkdir -p "$REPO/tools/blender"
echo "-- Скачиваю аддон Blender (blender-mcp)..."
curl -LsSf https://raw.githubusercontent.com/ahujasid/blender-mcp/main/addon.py -o "$REPO/tools/blender/addon.py"

echo "-- Прописываю MCP-серверы в ~/.codex/config.toml..."
mkdir -p "$HOME/.codex"
REPO_DIR="$REPO" python3 - <<'PY'
import os, re, pathlib
repo = os.environ['REPO_DIR']
block = pathlib.Path(repo, 'codex/config.toml.template').read_text(encoding='utf-8')
block = block.replace('{{REPO_DIR}}', repo).rstrip()
cfg = pathlib.Path.home() / '.codex' / 'config.toml'
cur = cfg.read_text(encoding='utf-8') if cfg.exists() else ''
begin, end = '# >>> oridium-designer-codex >>>', '# <<< oridium-designer-codex <<<'
if begin in cur:
    cur = re.sub(re.escape(begin) + r'.*?' + re.escape(end), block, cur, flags=re.S)
else:
    cur = (cur.rstrip() + '\n\n' + block + '\n').lstrip()
cfg.write_text(cur, encoding='utf-8')
print(f'   MCP-серверы прописаны в {cfg}')
PY

cat <<'EOF'

== Готово. Осталось по одному разу настроить программы — docs/SETUP.md:
   Figma:   Figma Desktop -> Dev Mode -> Enable MCP server
   Blender: установить аддон tools/blender/addon.py -> Connect
   Adobe:   UXP-плагины (PS/PR/ID) + CEP-расширения (AE/AI), см. docs/SETUP.md
   Прокси Adobe перед работой: scripts/start-adobe-proxy.sh
   Затем перезапусти VS Code / Codex.
EOF
