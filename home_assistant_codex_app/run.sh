#!/usr/bin/with-contenv bashio
set -euo pipefail

readonly CODEX_DATA_DIR="/config/codex"
readonly TERMINAL_INDEX="/tmp/ha-codex-terminal.html"

mkdir -p "${CODEX_DATA_DIR}"

# Persist the ChatGPT session and Codex settings in the add-on's own storage.
# The CLI binary is installed under /opt/codex at build time, so its managed
# package files are kept separate from this runtime configuration directory.
export CODEX_HOME="${CODEX_DATA_DIR}"

FONT_SIZE="$(bashio::config 'terminal_font_size')"
SCROLLBACK="$(bashio::config 'terminal_scrollback')"
THEME="$(bashio::config 'terminal_theme')"
PERSIST="$(bashio::config 'session_persistence')"
PRESERVE_HISTORY="$(bashio::config 'preserve_terminal_history')"
MODEL="$(bashio::config 'model')"
CODEX_TUI_FLAG=""
TERMINAL_MODE="fullscreen"

if [ "${PRESERVE_HISTORY}" = "true" ]; then
  CODEX_TUI_FLAG="--no-alt-screen"
  TERMINAL_MODE="inline"
fi

readonly SESSION_NAME="home-assistant-codex-${MODEL}-${TERMINAL_MODE}"
TTYD_INDEX_ARGS=()

if [ "${PERSIST}" = "true" ]; then
  COMMAND="tmux new-session -A -s ${SESSION_NAME} 'cd /homeassistant && codex ${CODEX_TUI_FLAG} --model ${MODEL}; exec bash -l'"
else
  COMMAND="cd /homeassistant && exec bash -lc 'codex ${CODEX_TUI_FLAG} --model ${MODEL}; exec bash -l'"
fi

bashio::log.info "Starting HA Codex."
bashio::log.info "Using Codex model: ${MODEL}."
bashio::log.info "Terminal history mode: ${TERMINAL_MODE}."
bashio::log.info "On first use, choose Sign in with ChatGPT in Codex."

# ttyd bundles its complete browser client inside its executable.  Home
# Assistant's embedded browser can hide the native xterm scrollbar, especially
# on touch devices, so derive that matching page and add an always-visible,
# touch-draggable scroll rail.  This keeps the page in lockstep with the ttyd
# version installed in the add-on instead of maintaining a separate copy.
GZIP_OFFSET="$(LC_ALL=C grep -abo $'\x1f\x8b\x08' /usr/local/bin/ttyd | head -n 1 | LC_ALL=C cut -d: -f1 || true)"
if [ -n "${GZIP_OFFSET}" ]; then
  dd if=/usr/local/bin/ttyd bs=1 skip="${GZIP_OFFSET}" 2>/dev/null | gzip -dc 2>/dev/null > "${TERMINAL_INDEX}" || true

  if [ -s "${TERMINAL_INDEX}" ] && grep -q '</html>' "${TERMINAL_INDEX}"; then
    sed -i 's@</head>@<style id="ha-codex-scrollbar-style">#ha-codex-scrollbar{position:fixed;z-index:50;top:12px;right:6px;bottom:12px;width:22px;border:1px solid rgba(255,255,255,.28);border-radius:12px;background:rgba(20,24,31,.72);box-shadow:0 1px 5px rgba(0,0,0,.55);touch-action:none;cursor:ns-resize}#ha-codex-scrollbar[hidden]{display:none}#ha-codex-scrollbar-thumb{position:absolute;left:3px;right:3px;min-height:36px;border-radius:9px;background:#e6a23c;box-shadow:inset 0 0 0 1px rgba(255,255,255,.35),0 1px 3px rgba(0,0,0,.5)}.xterm .xterm-viewport{scrollbar-width:auto!important;scrollbar-color:#e6a23c #20242d!important}.xterm .xterm-viewport::-webkit-scrollbar{width:15px!important}.xterm .xterm-viewport::-webkit-scrollbar-thumb{background:#e6a23c!important;border:3px solid #20242d!important;border-radius:9px!important}</style></head>@' "${TERMINAL_INDEX}"
    sed -i 's@</body>@<script id="ha-codex-scrollbar-script">(()=>{const start=()=>{const viewport=document.querySelector(".xterm-viewport");if(!viewport||document.getElementById("ha-codex-scrollbar")){return}const rail=document.createElement("div");const thumb=document.createElement("div");rail.id="ha-codex-scrollbar";rail.setAttribute("role","scrollbar");rail.setAttribute("aria-label","Terminal history");thumb.id="ha-codex-scrollbar-thumb";rail.appendChild(thumb);document.body.appendChild(rail);let dragging=false;const sync=()=>{const max=Math.max(0,viewport.scrollHeight-viewport.clientHeight);const track=rail.clientHeight;const thumbHeight=Math.max(36,Math.min(track,track*(viewport.clientHeight/Math.max(viewport.scrollHeight,1))));const available=Math.max(0,track-thumbHeight);thumb.style.height=`${thumbHeight}px`;thumb.style.transform=`translateY(${max?available*(viewport.scrollTop/max):0}px)`;rail.hidden=max<2};const move=clientY=>{const rect=rail.getBoundingClientRect();const max=Math.max(0,viewport.scrollHeight-viewport.clientHeight);const thumbHeight=thumb.getBoundingClientRect().height;const available=Math.max(1,rect.height-thumbHeight);const position=Math.max(0,Math.min(available,clientY-rect.top-thumbHeight/2));viewport.scrollTop=(position/available)*max;sync()};rail.addEventListener("pointerdown",event=>{dragging=true;rail.setPointerCapture(event.pointerId);move(event.clientY);event.preventDefault()});rail.addEventListener("pointermove",event=>{if(dragging){move(event.clientY)}});rail.addEventListener("pointerup",()=>{dragging=false});rail.addEventListener("pointercancel",()=>{dragging=false});viewport.addEventListener("scroll",sync,{passive:true});window.addEventListener("resize",sync);setInterval(sync,500);sync()};new MutationObserver(start).observe(document.documentElement,{childList:true,subtree:true});start()})();</script></body>@' "${TERMINAL_INDEX}"
    TTYD_INDEX_ARGS=(--index "${TERMINAL_INDEX}")
    bashio::log.info "Enabled visible terminal scrollbar."
  else
    bashio::log.warning "Could not prepare the enhanced terminal scrollbar; using ttyd's standard page."
  fi
else
  bashio::log.warning "Could not locate ttyd's browser client; using ttyd's standard page."
fi

exec /usr/local/bin/ttyd \
  --writable \
  --port 7681 \
  --terminal-type xterm-256color \
  --client-option "fontSize=${FONT_SIZE}" \
  --client-option "scrollback=${SCROLLBACK}" \
  --client-option "theme=${THEME}" \
  "${TTYD_INDEX_ARGS[@]}" \
  bash -lc "${COMMAND}"
