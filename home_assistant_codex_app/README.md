# Home Assistant Codex App

Use OpenAI Codex in a Home Assistant sidebar workspace. The add-on starts a
persistent web terminal in `/homeassistant`, which is your Home Assistant
configuration directory.

## What it can do

- Review and edit YAML, dashboards, automations, scripts, packages, and custom components.
- Run local commands such as `git diff`, `rg`, and Home Assistant configuration checks available in the container.
- Keep a Codex session alive while you leave and return to the Home Assistant sidebar.

It deliberately does **not** request host networking, Docker access, full host
access, or a Supervisor token.

## Install

1. In Home Assistant, open **Settings → Add-ons → Add-on Store → ⋮ → Repositories**.
2. Add `https://github.com/ambient-home-systems/home-assistant-codex-app`.
3. Install **Home Assistant Codex App**, start it, and enable **Show in sidebar**.

## First sign-in

Open the sidebar item. Codex starts automatically. On first use, select
**Sign in with ChatGPT**, complete the browser sign-in, then return to the
terminal. Your Codex session is stored in the add-on's private configuration
folder and persists across restarts.

## Safe workflow

Before asking Codex to change files, start with:

```text
Review my Home Assistant configuration. Do not make any edits; first explain your findings.
```

Before applying a change, use:

```text
Show the exact files and diff you propose. Do not restart Home Assistant.
```

Create a Home Assistant backup and a Git checkpoint before significant edits.

## Limitations

This is a terminal-based Codex workspace, not an Assist conversation agent. It
can read and edit `/homeassistant` because that directory is intentionally
mounted read/write. It cannot control Docker, access the host, or use a
Supervisor token. Keep access to your Home Assistant account protected.
