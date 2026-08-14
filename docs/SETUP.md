# Настройка программ (по одному разу)

Перед этим должна быть выполнена установка (`setup/install.ps1` или `setup/install.sh`).

## Figma

1. Открой **десктопное** приложение Figma (в браузере MCP-сервер не работает).
2. Открой любой дизайн-файл → переключись в **Dev Mode** (тумблер в тулбаре, нужен план с Dev Mode).
3. В правой панели включи **Enable MCP server**. Внизу появится подтверждение — сервер слушает `http://127.0.0.1:3845/mcp`, ровно этот адрес уже прописан в конфиге.
4. Работая с агентом, выделяй в Figma нужный фрейм — агент читает текущее выделение.

Официальная инструкция: https://help.figma.com/hc/en-us/articles/32132100833559

## Blender

Используй Blender 4.2 или новее: эта версия нужна встроенному оптимизатору моделей.

1. **Edit → Preferences → Add-ons → Install from Disk** → выбери `tools/blender/addon.py` из этого репозитория и включи **Interface: Blender MCP**.
2. Там же нажми **Install from Disk** → выбери `tools/blender/blender_model_optimizer-2.1.1.zip` и включи **3D Model Optimizer**.
3. В 3D-виде открой сайдбар (клавиша `N`) → вкладка **BlenderMCP** → **Connect to Claude** (кнопка называется так, работает с любым MCP-клиентом, включая Codex).
4. Оптимизатор появится во вкладке **3D Optimizer**. Для рабочей модели попроси помощника «безопасно уменьши полигоны» — он сохранит исходник, запустит анализ и проверит результат до/после.
5. По желанию — включи Poly Haven (бесплатные ассеты) во вкладке BlenderMCP.

Проверенные копии обоих аддонов уже лежат в `tools/blender`; совместимая версия MCP-сервера закреплена в конфиге. 3D Model Optimizer закреплён на версии 2.1.1 и распространяется по лицензии MIT: https://github.com/Hinneman/blender-model-optimizer
Телеметрия Blender MCP в готовом конфиге отключена.

Не запускай **Run Full Pipeline** на единственном рабочем объекте: заводские настройки могут оставить около 10% полигонов, объединить объекты и удалить мелкие детали. Помощник использует безопасные настройки на копии; более агрессивные действия включает только после проверки.

## Adobe (Photoshop, Illustrator, After Effects, InDesign, Premiere Pro)

Общая схема adb-mcp: MCP-сервер (уже в конфиге) ⇄ **прокси** ⇄ **плагин внутри приложения**.

### Прокси

Запускай перед каждой рабочей сессией и держи окно открытым:
- macOS: `scripts/start-adobe-proxy.sh`
- Windows: `scripts/start-adobe-proxy.ps1`

### UXP-плагины — Photoshop, Premiere Pro, InDesign

1. В Creative Cloud установи **UXP Developer Tool** (вкладка «Все приложения» → поиск).
2. Открой UXP Developer Tool → **Add Plugin** → выбери `manifest.json`:
   - Photoshop: `vendor/adb-mcp/uxp/ps/manifest.json`
   - Premiere: `vendor/adb-mcp/uxp/pr/manifest.json`
   - InDesign: `vendor/adb-mcp/uxp/id/manifest.json`
3. При открытом целевом приложении нажми **Load** у плагина — в приложении появится панель, в ней **Connect**.
4. После перезапуска приложения плагин нужно загружать заново (Load) — это ограничение режима разработчика UXP.

### CEP-расширения — After Effects, Illustrator

macOS (Терминал, из папки репозитория):

```bash
defaults write com.adobe.CSXS.11 PlayerDebugMode 1
mkdir -p ~/Library/Application\ Support/Adobe/CEP/extensions
ln -s "$PWD/vendor/adb-mcp/cep/com.mikechambers.ae" ~/Library/Application\ Support/Adobe/CEP/extensions/
ln -s "$PWD/vendor/adb-mcp/cep/com.mikechambers.ai" ~/Library/Application\ Support/Adobe/CEP/extensions/
```

Windows (PowerShell от администратора, репозиторий в `C:\путь\до\Oridium-Designer-Codex`):

```powershell
# разрешить неподписанные расширения
reg add HKCU\SOFTWARE\Adobe\CSXS.11 /v PlayerDebugMode /t REG_SZ /d 1 /f
# симлинки расширений
$ext = "$env:APPDATA\Adobe\CEP\extensions"
New-Item -ItemType Directory -Force $ext | Out-Null
cmd /c mklink /D "$ext\com.mikechambers.ae" "C:\путь\до\Oridium-Designer-Codex\vendor\adb-mcp\cep\com.mikechambers.ae"
cmd /c mklink /D "$ext\com.mikechambers.ai" "C:\путь\до\Oridium-Designer-Codex\vendor\adb-mcp\cep\com.mikechambers.ai"
```

Затем в приложении: **Window → Extensions** → открой панель adb-mcp → **Connect**.
Если панели нет — у твоей версии приложения другой номер CSXS (10/11/12): повтори команду PlayerDebugMode с соседними номерами.

Репозиторий и подробности: https://github.com/mikechambers/adb-mcp

## Проверка

Открой папку репозитория в VS Code, запусти Codex и спроси: «какие MCP-инструменты тебе доступны?» — в списке должны быть figma, blender, photoshop, premiere, indesign, after_effects, illustrator.
