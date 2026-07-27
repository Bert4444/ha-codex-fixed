# HA Codex

Use OpenAI Codex in a Home Assistant sidebar workspace. The add-on starts a
persistent web terminal in `/homeassistant`, which is your Home Assistant
configuration directory.

## What it can do

- Review and edit YAML, dashboards, automations, scripts, packages, and custom components.
- Run local commands such as `git diff`, `rg`, and Home Assistant configuration checks available in the container.
- Keep a Codex session alive while you leave and return to the Home Assistant sidebar.

It deliberately does **not** request host networking, Docker access, full host
access, or a Supervisor token.

## Install from a personal repository

1. In Home Assistant, open **Settings → Add-ons → Add-on Store → ⋮ → Repositories**.
2. Add `https://github.com/ambient-home-systems/ha-codex`.
3. Install **HA Codex**, start it, and enable **Show in sidebar**.

## First sign-in

Open the sidebar item. Codex starts automatically. On first use, HA Codex
shows a two-option sign-in menu. After updating from an earlier version,
restart HA Codex to begin this revised sign-in flow in a fresh session.

1. **Log in with a different device (Preferred Method):** complete the secure,
   one-time code sign-in from a phone, tablet, or another computer, then return
   to HA Codex. This avoids browser and pop-up limits in the embedded Home
   Assistant page.
2. **OpenAI API key** (only if the Codex sign-in screen offers it): this uses a
   separate, usage-billed OpenAI Platform account, not a ChatGPT subscription.
   Keep API keys private and never add one to Home Assistant configuration or
   repository files.

Your Codex session is stored in the add-on's private configuration folder and
persists across restarts.

## Model choice

HA Codex defaults to **GPT-5.6 Terra**, the balanced choice for most Home
Assistant configuration reviews and edits. The Configuration tab also offers
GPT-5.6 Sol (hard, open-ended work), GPT-5.6 Luna (clear, repeatable work),
GPT-5.6, GPT-5.5, GPT-5.4, GPT-5.4 Mini, and the ChatGPT Pro-only GPT-5.3
Codex Spark preview.

This setting launches Codex with the selected model every time the add-on
starts, so it is the durable default. Use `/model` inside Codex to change the
currently active session immediately. Restart the add-on after changing the
Configuration setting; your ChatGPT plan determines which listed models are
available to you.

## Add-on settings

Select the model you want in the add-on's **Configuration** tab before
starting HA Codex. Change any other settings there as needed, then restart HA
Codex.

| Setting | Default | What it does |
| --- | --- | --- |
| **Model** | GPT-5.6 Terra | Starts new Codex sessions with Terra. Use Sol only for unusually difficult or broad work. |
| **Terminal font size** | 14 | Sets terminal text size (10–24). |
| **Terminal scrollback** | 10,000 lines | Keeps 1,000–50,000 lines of past terminal output in the browser. |
| **Terminal theme** | Dark | Sets the terminal color theme. |
| **Session persistence** | On | Keeps the terminal session alive when you leave the sidebar. |
| **Preserve terminal history** | On | Runs Codex in inline transcript mode so browser scrollback works for long reviews. Recommended. |

For long reviews, leave **Preserve terminal history** on. HA Codex reserves a
slim right-side history gutter: drag the golden handle, use the **up/down
arrows**, use a mouse wheel or trackpad, or swipe inside the terminal on a touch
device.
Raise **Terminal scrollback** only if 10,000 lines is not enough.

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
