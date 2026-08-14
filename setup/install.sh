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

RTK_VERSION="v0.45.0"
RTK_BIN="$HOME/.local/bin/rtk"
if [[ ! -x "$RTK_BIN" ]] || [[ "$("$RTK_BIN" --version 2>/dev/null || true)" != "rtk ${RTK_VERSION#v}" ]]; then
  echo "-- Ставлю RTK ${RTK_VERSION} (экономия токенов)..."
  curl -fsSL "https://raw.githubusercontent.com/rtk-ai/rtk/${RTK_VERSION}/install.sh" | RTK_VERSION="$RTK_VERSION" sh
fi
export PATH="$HOME/.local/bin:$PATH"
need rtk "Установка RTK не удалась: https://github.com/rtk-ai/rtk"
echo "-- Настраиваю RTK для Codex..."
RTK_TELEMETRY_DISABLED=1 "$RTK_BIN" init -g --codex

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

BLENDER_MCP_ADDON="$REPO/tools/blender/addon.py"
BLENDER_OPTIMIZER_ADDON="$REPO/tools/blender/blender_model_optimizer-2.1.1.zip"
for addon in "$BLENDER_MCP_ADDON" "$BLENDER_OPTIMIZER_ADDON"; do
  if [[ ! -s "$addon" ]]; then
    echo "ОШИБКА: в репозитории нет $addon" >&2
    exit 1
  fi
done
echo "-- Аддоны Blender MCP и 3D Model Optimizer уже включены в репозиторий."

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
   RTK для экономии токенов уже установлен и подключён к Codex.
   Figma:   Figma Desktop -> Dev Mode -> Enable MCP server
   Blender: установить два аддона из tools/blender (см. docs/SETUP.md) -> Connect
   Adobe:   UXP-плагины (PS/PR/ID) + CEP-расширения (AE/AI), см. docs/SETUP.md
   Прокси Adobe перед работой: scripts/start-adobe-proxy.sh
   Затем перезапусти VS Code / Codex.
EOF
