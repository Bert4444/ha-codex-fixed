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
TERMINAL_MODE="fullscreen"

if [ "${PRESERVE_HISTORY}" = "true" ]; then
  TERMINAL_MODE="inline"
fi

readonly AUTH_FLOW_VERSION="device-code-v1"
readonly SESSION_NAME="home-assistant-codex-${MODEL}-${TERMINAL_MODE}-${AUTH_FLOW_VERSION}"
TTYD_INDEX_ARGS=()

if [ "${PERSIST}" = "true" ]; then
  COMMAND="tmux new-session -A -s ${SESSION_NAME} '/usr/local/bin/ha-codex-session ${MODEL} ${TERMINAL_MODE}; exec bash -l'"
else
  COMMAND="exec /usr/local/bin/ha-codex-session ${MODEL} ${TERMINAL_MODE}"
fi

bashio::log.info "Starting HA Codex."
bashio::log.info "Using Codex model: ${MODEL}."
bashio::log.info "Terminal history mode: ${TERMINAL_MODE}."
bashio::log.info "First-time sign-in uses the HA Codex device-code method by default."

# ttyd bundles its complete browser client inside its executable.  Home
# Assistant's embedded browser can hide the native xterm scrollbar, especially
# on touch devices, so derive that matching page and add an always-visible,
# touch-draggable scroll rail.  This keeps the page in lockstep with the ttyd
# version installed in the add-on instead of maintaining a separate copy.
GZIP_OFFSET="$(LC_ALL=C grep -abo $'\x1f\x8b\x08' /usr/local/bin/ttyd | head -n 1 | LC_ALL=C cut -d: -f1 || true)"
if [ -n "${GZIP_OFFSET}" ]; then
  dd if=/usr/local/bin/ttyd bs=1 skip="${GZIP_OFFSET}" 2>/dev/null | gzip -dc 2>/dev/null > "${TERMINAL_INDEX}" || true

  if [ -s "${TERMINAL_INDEX}" ] && grep -q '</html>' "${TERMINAL_INDEX}"; then
    sed -i "s@</head>@<script>window.__HA_CODEX_SCROLLBACK__=${SCROLLBACK};</script></head>@" "${TERMINAL_INDEX}"
    sed -i 's@</head>@<style id="ha-codex-scrollbar-style">#terminal-container{box-sizing:border-box!important;padding-right:36px!important}#terminal-container .terminal{box-sizing:border-box!important;width:100%!important}#ha-codex-scrollbar{position:fixed;z-index:50;top:6px;right:4px;bottom:6px;width:28px;display:flex;flex-direction:column;gap:4px;padding:2px;border-left:1px solid rgba(127,127,127,.32);background:rgba(32,36,45,.86);box-sizing:border-box}#ha-codex-scrollbar[hidden]{display:none}.ha-codex-scroll-button{height:26px;padding:0;border:1px solid #6b5734;border-radius:5px;background:#3a3225;color:#f6c66f;font:700 18px/1 sans-serif;touch-action:manipulation}.ha-codex-scroll-button:focus-visible{outline:2px solid #f6c66f;outline-offset:1px}.ha-codex-scroll-track{position:relative;flex:1;min-height:44px;border-radius:6px;background:#15191f;touch-action:none;cursor:ns-resize}.ha-codex-scroll-thumb{position:absolute;left:3px;right:3px;min-height:28px;border-radius:5px;background:#e6a23c;box-shadow:inset 0 0 0 1px rgba(255,255,255,.35)}.xterm .xterm-viewport{scrollbar-width:none!important}.xterm .xterm-viewport::-webkit-scrollbar{display:none!important}</style></head>@' "${TERMINAL_INDEX}"
    sed -i 's@</body>@<script id="ha-codex-buffer-scrollbar-script">(()=>{const start=()=>{const term=window.term;if(!term||document.getElementById("ha-codex-buffer-scrollbar")){return}const configured=Number(window.__HA_CODEX_SCROLLBACK__);if(Number.isFinite(configured)&&configured>0){term.options.scrollback=configured}document.getElementById("ha-codex-scrollbar")?.remove();const rail=document.createElement("div");const top=document.createElement("button");const bottom=document.createElement("button");const track=document.createElement("div");const thumb=document.createElement("div");rail.id="ha-codex-buffer-scrollbar";rail.className="ha-codex-scrollbar";rail.setAttribute("aria-label","Terminal history controls");top.type="button";top.className="ha-codex-scroll-button";top.textContent="↑";top.setAttribute("aria-label","Scroll to beginning of terminal history");top.title="Beginning of history";bottom.type="button";bottom.className="ha-codex-scroll-button";bottom.textContent="↓";bottom.setAttribute("aria-label","Scroll to latest terminal output");bottom.title="Latest output";track.className="ha-codex-scroll-track";thumb.className="ha-codex-scroll-thumb";track.appendChild(thumb);rail.append(top,track,bottom);document.body.appendChild(rail);let dragging=false;const range=()=>term.buffer.active.baseY;const position=()=>term.buffer.active.viewportY;const sync=()=>{const total=range();const height=track.clientHeight;const thumbHeight=Math.max(28,Math.min(height,height*((term.rows||1)/Math.max(term.buffer.active.length,1))));const available=Math.max(0,height-thumbHeight);thumb.style.height=thumbHeight+"px";thumb.style.transform="translateY("+(total?available*(position()/total):0)+"px)";rail.hidden=total<1};const move=y=>{const rect=track.getBoundingClientRect();const thumbHeight=thumb.getBoundingClientRect().height;const available=Math.max(1,rect.height-thumbHeight);const fraction=Math.max(0,Math.min(1,(y-rect.top-thumbHeight/2)/available));term.scrollLines(Math.round(fraction*range())-position());sync()};top.addEventListener("click",()=>{term.scrollToTop();sync()});bottom.addEventListener("click",()=>{term.scrollToBottom();sync()});track.addEventListener("pointerdown",event=>{dragging=true;track.setPointerCapture(event.pointerId);move(event.clientY);event.preventDefault()});track.addEventListener("pointermove",event=>{if(dragging){move(event.clientY)}});["pointerup","pointercancel","lostpointercapture"].forEach(type=>track.addEventListener(type,()=>{dragging=false}));term.onScroll(sync);window.addEventListener("resize",sync);setInterval(sync,400);sync()};new MutationObserver(start).observe(document.documentElement,{childList:true,subtree:true});start()})();</script></body>@' "${TERMINAL_INDEX}"
    sed -i 's@</body>@<script id="ha-codex-scrollbar-script">(()=>{const start=()=>{const viewport=document.querySelector(".xterm-viewport");if(!viewport||document.getElementById("ha-codex-scrollbar")){return}const rail=document.createElement("div");const top=document.createElement("button");const bottom=document.createElement("button");const track=document.createElement("div");const thumb=document.createElement("div");rail.id="ha-codex-scrollbar";rail.setAttribute("aria-label","Terminal history controls");top.type="button";top.className="ha-codex-scroll-button";top.textContent="↑";top.setAttribute("aria-label","Scroll to beginning of terminal history");top.title="Beginning of history";bottom.type="button";bottom.className="ha-codex-scroll-button";bottom.textContent="↓";bottom.setAttribute("aria-label","Scroll to latest terminal output");bottom.title="Latest output";track.className="ha-codex-scroll-track";thumb.className="ha-codex-scroll-thumb";track.appendChild(thumb);rail.append(top,track,bottom);document.body.appendChild(rail);let dragging=false;const max=()=>Math.max(0,viewport.scrollHeight-viewport.clientHeight);const sync=()=>{const range=max();const height=track.clientHeight;const thumbHeight=Math.max(28,Math.min(height,height*(viewport.clientHeight/Math.max(viewport.scrollHeight,1))));const available=Math.max(0,height-thumbHeight);thumb.style.height=thumbHeight+"px";thumb.style.transform="translateY("+(range?available*(viewport.scrollTop/range):0)+"px)";rail.hidden=range<2};const move=y=>{const rect=track.getBoundingClientRect();const thumbHeight=thumb.getBoundingClientRect().height;const available=Math.max(1,rect.height-thumbHeight);const position=Math.max(0,Math.min(available,y-rect.top-thumbHeight/2));viewport.scrollTop=(position/available)*max();sync()};top.addEventListener("click",()=>{viewport.scrollTop=0;sync()});bottom.addEventListener("click",()=>{viewport.scrollTop=max();sync()});track.addEventListener("pointerdown",event=>{dragging=true;track.setPointerCapture(event.pointerId);move(event.clientY);event.preventDefault()});track.addEventListener("pointermove",event=>{if(dragging){move(event.clientY)}});["pointerup","pointercancel","lostpointercapture"].forEach(type=>track.addEventListener(type,()=>{dragging=false}));viewport.addEventListener("scroll",sync,{passive:true});window.addEventListener("resize",sync);setInterval(sync,400);sync()};new MutationObserver(start).observe(document.documentElement,{childList:true,subtree:true});start()})();</script></body>@' "${TERMINAL_INDEX}"
    sed -i 's/ha-codex-buffer-scrollbar/ha-codex-scrollbar/g' "${TERMINAL_INDEX}"
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
