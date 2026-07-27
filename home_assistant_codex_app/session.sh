#!/usr/bin/env bash
set -u

readonly MODEL="$1"
readonly TERMINAL_MODE="$2"

cd /homeassistant

if ! codex login status >/dev/null 2>&1; then
  clear
  printf '%s\n' \
    'HA Codex sign in' \
    '' \
    '1. Sign in with Device Code (Preferred Method)' \
    '   Sign in from another device with a secure, one-time code.' \
    '' \
    '2. Provide your own API key' \
    '   Pay for usage through an OpenAI Platform account.' \
    ''

  while true; do
    printf 'Select 1 or 2: '
    IFS= read -r choice || exit 1

    case "${choice}" in
      1)
        if codex login --device-auth; then
          break
        fi
        printf '\nDevice-code sign-in did not complete. Please try again.\n\n'
        ;;
      2)
        printf 'Paste your OpenAI API key (input is hidden): '
        IFS= read -r -s api_key || exit 1
        printf '\n'

        if [ -z "${api_key}" ]; then
          printf 'An API key is required. Please try again.\n\n'
        elif printf '%s' "${api_key}" | codex login --with-api-key; then
          unset api_key
          break
        else
          unset api_key
          printf '\nAPI-key sign-in did not complete. Please try again.\n\n'
        fi
        ;;
      *)
        printf 'Please enter 1 or 2.\n\n'
        ;;
    esac
  done
fi

if [ "${TERMINAL_MODE}" = "inline" ]; then
  exec codex --no-alt-screen --model "${MODEL}"
fi

exec codex --model "${MODEL}"
