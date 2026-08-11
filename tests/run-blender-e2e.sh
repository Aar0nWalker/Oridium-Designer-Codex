#!/usr/bin/env bash
set -euo pipefail

BLENDER_LOG=/tmp/oridium-blender.log
xvfb-run -a -s '-screen 0 1280x720x24' \
  blender --factory-startup --python /src/tests/blender-e2e.py -- startup \
  > "$BLENDER_LOG" 2>&1 &
BLENDER_PID=$!
cleanup() {
  status=$?
  if (( status != 0 )); then
    echo "--- Blender log ---" >&2
    sed -n '1,240p' "$BLENDER_LOG" >&2
  fi
  kill "$BLENDER_PID" 2>/dev/null || true
  return "$status"
}
trap cleanup EXIT

python3 - <<'PY'
import socket
import time

for _ in range(120):
    try:
        with socket.create_connection(("127.0.0.1", 9876), timeout=1):
            print("OK: Blender-аддон слушает 127.0.0.1:9876")
            break
    except OSError:
        time.sleep(0.5)
else:
    raise SystemExit("Blender MCP не запустился")
PY

uv run --with 'mcp<2' python /src/tests/blender-e2e.py client
test -s /output/oridium-mcp-test.blend
test -s /output/oridium-mcp-test.png
blender -b /output/oridium-mcp-test.blend --python-exit-code 1 --python-expr \
  "import bpy; expected={'test_ground','mcp_hero_cube','mcp_orbit_ring','key_light','fill_light','test_camera'}; assert expected <= set(bpy.data.objects.keys()); assert bpy.context.scene.camera.name == 'test_camera'"
echo "OK: созданы /output/oridium-mcp-test.blend и /output/oridium-mcp-test.png"
