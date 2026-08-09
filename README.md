# Oridium Designer Codex

Готовый набор для дизайнера: AI-агент [Codex](https://openai.com/codex/) управляет **Figma, Blender, Photoshop, Illustrator, After Effects, InDesign и Premiere Pro** прямо из VS Code — через MCP-серверы и скиллы, которые уже настроены в этом репозитории.

Скачал → запустил установку → открыл папку в VS Code → работаешь с агентом во всех программах.

## Что внутри

| Программа | Как подключается |
|---|---|
| Figma | Официальный [Dev Mode MCP server](https://help.figma.com/hc/en-us/articles/32132100833559) (встроен в Figma Desktop) |
| Blender | [blender-mcp](https://github.com/ahujasid/blender-mcp) — моделинг, сцены, материалы, рендер по команде |
| Photoshop | [adb-mcp](https://github.com/mikechambers/adb-mcp) — слои, текст, фильтры, выделения, экспорт |
| Illustrator | adb-mcp (ExtendScript) — векторная графика скриптами |
| After Effects | adb-mcp (ExtendScript) — композиции, слои, анимация |
| InDesign | adb-mcp — вёрстка, стили, документы |
| Premiere Pro | adb-mcp — таймлайн, клипы, монтаж |

Скиллы для каждой программы лежат в [.agents/skills/](.agents/skills/) — Codex подхватывает их автоматически, когда открыта папка репозитория.

## Установка

### 1. Поставь базовые программы

- [VS Code](https://code.visualstudio.com/) — редактор, в котором живёт агент.
- [Codex — расширение VS Code](https://marketplace.visualstudio.com/items?itemName=openai.chatgpt) (нужна подписка ChatGPT Plus/Pro/Team). Альтернатива — [Codex CLI](https://developers.openai.com/codex/cli): `npm i -g @openai/codex`.
- [Node.js LTS](https://nodejs.org/) и [Git](https://git-scm.com/downloads) — нужны установщику.

### 2. Скачай репозиторий и запусти установку

**Windows** (PowerShell):

```powershell
git clone https://github.com/Aar0nWalker/Oridium-Designer-Codex
cd Oridium-Designer-Codex
powershell -ExecutionPolicy Bypass -File setup/install.ps1
```

**macOS / Linux**:

```bash
git clone https://github.com/Aar0nWalker/Oridium-Designer-Codex
cd Oridium-Designer-Codex
bash setup/install.sh
```

Установщик сам: поставит `uv` (если нет), скачает adb-mcp и blender-mcp, установит зависимости прокси и пропишет все MCP-серверы в `~/.codex/config.toml` (свои существующие настройки не потеряешь — блок помечен маркерами).

### 3. Донастрой программы (по одному разу)

Подробно по каждой — [docs/SETUP.md](docs/SETUP.md). Коротко:

- **Figma**: Figma Desktop → Dev Mode → включить MCP server.
- **Blender**: установить аддон `tools/blender/addon.py` (Edit → Preferences → Add-ons → Install), в сайдбаре нажать Connect.
- **Adobe**: установить UXP-плагины через [UXP Developer Tool](https://developer.adobe.com/photoshop/uxp/2022/guides/devtool/) (Photoshop / Premiere / InDesign) и CEP-расширения симлинком (After Effects / Illustrator).

### 4. Работай

1. Запусти прокси Adobe (нужен, только если работаешь с Adobe-программами): `scripts/start-adobe-proxy.ps1` (Windows) или `scripts/start-adobe-proxy.sh` (macOS).
2. Открой нужную программу (Figma / Blender / Photoshop …) и подключи её плагин.
3. Открой папку репозитория в VS Code → запусти Codex → говори, что сделать:

> «Возьми выделенный фрейм в Figma и свёрстай его в HTML»
> «Сделай в Blender низкополигональную сцену с горами на закате»
> «В Photoshop подними контраст, добавь заголовок Montserrat 120px и экспортни PNG»

## Частые проблемы

- **Codex не видит MCP-серверы** — перезапусти Codex/VS Code после установки; проверь `~/.codex/config.toml`.
- **Adobe-инструменты молчат** — проверь цепочку: прокси запущен → приложение открыто → плагин в приложении подключён (Connect).
- **Figma не отвечает** — MCP-сервер работает только в **десктопном** приложении Figma при включённом Dev Mode.
- **Первый запуск Adobe-сервера долгий** — `uv` качает зависимости, дальше мгновенно.

## Лицензия

MIT. Сторонние проекты (adb-mcp, blender-mcp) ставятся отдельно и живут под своими лицензиями.
