#!/usr/bin/env bash
set -euo pipefail

SOURCE=${SOURCE:-/src}
WORK=$(mktemp -d)
TEST_HOME=$(mktemp -d)
PROXY_PID=
cleanup() {
  [ -z "$PROXY_PID" ] || kill "$PROXY_PID" 2>/dev/null || true
  rm -rf "$WORK" "$TEST_HOME"
}
trap cleanup EXIT

cp -a "$SOURCE/." "$WORK/"
rm -rf "$WORK/vendor"
export HOME=$TEST_HOME
cd "$WORK"
FAILURES=0

echo "-- Чистая установка"
if bash setup/install.sh; then
  echo "-- Повторная установка"
  bash setup/install.sh || FAILURES=$((FAILURES + 1))
else
  echo "FAIL: чистая установка не завершилась"
  FAILURES=$((FAILURES + 1))
fi
export PATH="$HOME/.local/bin:$PATH"

if [ ! -f "$HOME/.codex/config.toml" ]; then
  echo "-- Установщик не дошёл до конфига; проверяю шаблон отдельно"
  python3 - "$HOME/.codex/config.toml" <<'PY'
import pathlib
import sys

config_path = pathlib.Path(sys.argv[1])
config_path.parent.mkdir(parents=True, exist_ok=True)
text = pathlib.Path("codex/config.toml.template").read_text(encoding="utf-8")
config_path.write_text(text.replace("{{REPO_DIR}}", str(pathlib.Path.cwd())), encoding="utf-8")
PY
fi

python3 - "$HOME/.codex/config.toml" <<'PY'
import pathlib
import sys
import tomllib

config_path = pathlib.Path(sys.argv[1])
text = config_path.read_text(encoding="utf-8")
assert text.count("# >>> oridium-designer-codex >>>") == 1
assert text.count("# <<< oridium-designer-codex <<<") == 1
assert "{{REPO_DIR}}" not in text

servers = tomllib.loads(text)["mcp_servers"]
expected = {
    "figma", "blender", "photoshop", "premiere", "indesign",
    "after_effects", "illustrator",
}
assert set(servers) == expected
assert servers["figma"]["url"] == "http://127.0.0.1:3845/mcp"
assert servers["blender"]["command"] == "uvx"
assert servers["blender"]["args"] == ["blender-mcp==1.8.0"]
assert servers["blender"]["env"]["BLENDER_MCP_DISABLE_TELEMETRY"] == "true"
for name in expected - {"figma", "blender"}:
    assert servers[name]["command"] == "uv"
    assert pathlib.Path(servers[name]["args"][-1]).is_file()
print("OK: MCP-конфиг валиден, содержит 7 серверов и один управляемый блок")
PY

if [ ! -s tools/blender/addon.py ]; then
  echo "FAIL: Blender-аддон отсутствует в репозитории"
  FAILURES=$((FAILURES + 1))
fi
test -d vendor/adb-mcp/adb-proxy-socket/node_modules
test -f vendor/adb-mcp/uxp/ps/manifest.json
test -f vendor/adb-mcp/uxp/pr/manifest.json
test -f vendor/adb-mcp/uxp/id/manifest.json
test -f vendor/adb-mcp/cep/com.mikechambers.ae/CSXS/manifest.xml
test -f vendor/adb-mcp/cep/com.mikechambers.ai/CSXS/manifest.xml
echo "OK: пять Adobe-плагинов на месте"

echo "-- Запуск Adobe-прокси"
bash scripts/start-adobe-proxy.sh > /tmp/oridium-proxy.log 2>&1 &
PROXY_PID=$!
for _ in $(seq 1 30); do
  if node -e 'const s=require("net").connect(3001,"127.0.0.1",()=>{s.end();process.exit(0)});s.on("error",()=>process.exit(1))'; then
    break
  fi
  sleep 0.2
done
node <<'JS'
const { io } = require("./vendor/adb-mcp/adb-proxy-socket/node_modules/socket.io-client");
const socket = io("http://127.0.0.1:3001", { transports: ["websocket"], timeout: 5000 });
const timer = setTimeout(() => { console.error("FAIL: нет ответа регистрации"); process.exit(1); }, 5000);
socket.on("connect", () => socket.emit("register", { application: "smoke-test" }));
socket.on("registration_response", (response) => {
  clearTimeout(timer);
  socket.close();
  if (response.status !== "success") process.exit(1);
});
socket.on("disconnect", () => process.exit(0));
socket.on("connect_error", (error) => { console.error(error); process.exit(1); });
JS
echo "OK: Adobe-прокси отвечает на Socket.IO-регистрацию"

echo "-- MCP handshake без графических приложений"
uv run --with 'mcp<2' python - "$HOME/.codex/config.toml" <<'PY'
import asyncio
import os
import sys
import tomllib

from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

servers = tomllib.load(open(sys.argv[1], "rb"))["mcp_servers"]

async def check(name):
    server = servers[name]
    params = StdioServerParameters(
        command=server["command"],
        args=server.get("args", []),
        env={**os.environ, **server.get("env", {})},
    )
    async with stdio_client(params) as (read, write):
        async with ClientSession(read, write) as session:
            await asyncio.wait_for(session.initialize(), timeout=120)
            tools = await asyncio.wait_for(session.list_tools(), timeout=120)
            assert tools.tools, f"{name}: пустой список инструментов"
            print(f"OK: {name} — MCP handshake, инструментов {len(tools.tools)}")

async def main():
    for name in ("blender", "photoshop", "premiere", "indesign", "after_effects", "illustrator"):
        await check(name)

asyncio.run(main())
PY

kill "$PROXY_PID"
wait "$PROXY_PID" 2>/dev/null || true
PROXY_PID=
if [ "$FAILURES" -ne 0 ]; then
  echo "== Docker smoke-тест завершён: ошибок $FAILURES"
  exit 1
fi
echo "== Docker smoke-тест пройден полностью"
