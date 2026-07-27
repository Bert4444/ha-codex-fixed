#!/usr/bin/with-contenv bashio
set -euo pipefail

readonly CODEX_DATA_DIR="/config/codex"
readonly SESSION_NAME="home-assistant-codex"

mkdir -p "${CODEX_DATA_DIR}"

# Persist the ChatGPT session and Codex settings in the add-on's own storage.
# The CLI binary is installed under /opt/codex at build time, so its managed
# package files are kept separate from this runtime configuration directory.
export CODEX_HOME="${CODEX_DATA_DIR}"

FONT_SIZE="$(bashio::config 'terminal_font_size')"
THEME="$(bashio::config 'terminal_theme')"
PERSIST="$(bashio::config 'session_persistence')"

if [ "${PERSIST}" = "true" ]; then
  COMMAND="tmux new-session -A -s ${SESSION_NAME} 'cd /homeassistant && codex; exec bash -l'"
else
  COMMAND="cd /homeassistant && exec bash -lc 'codex; exec bash -l'"
fi

bashio::log.info "Starting Home Assistant Codex App."
bashio::log.info "On first use, choose Sign in with ChatGPT in Codex."

exec /usr/local/bin/ttyd \
  --writable \
  --port 7681 \
  --terminal-type xterm-256color \
  --client-option "fontSize=${FONT_SIZE}" \
  --client-option "theme=${THEME}" \
  bash -lc "${COMMAND}"
