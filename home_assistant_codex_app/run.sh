#!/usr/bin/with-contenv bashio
set -euo pipefail

readonly CODEX_HOME="/config/codex"
readonly SESSION_NAME="home-assistant-codex"

mkdir -p "${CODEX_HOME}"

# Persist the ChatGPT session and Codex settings in the add-on's own storage.
# This avoids putting credentials in /homeassistant or the add-on option form.
if [ -e /root/.codex ] && [ ! -L /root/.codex ]; then
  rm -rf /root/.codex
fi
ln -sfn "${CODEX_HOME}" /root/.codex

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
