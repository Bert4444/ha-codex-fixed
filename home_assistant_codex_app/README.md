# HA Codex

Use OpenAI Codex in a Home Assistant sidebar workspace. The add-on starts a
persistent web terminal in `/homeassistant`, which is your Home Assistant
configuration directory.

☕ [Support HA Codex and future Home Assistant add-on development](https://www.buymeacoffee.com/Joshua.ambient.home)

> [!IMPORTANT]
> ## Enable Home Assistant reload and restart actions
>
> Open **HA Codex → Configuration**. Turn on **Allow Home Assistant control
> actions**, then **restart HA Codex**. This enables configuration validation
> and supported reload actions. To let Codex restart Home Assistant Core, also
> turn on **Allow Home Assistant Core restart**. Both settings are off by
> default; no token, IP address, or host setup is required.

## What it can do

- Review and edit YAML, dashboards, automations, scripts, packages, and custom components.
- Run local commands such as `git diff`, `rg`, and Home Assistant configuration checks available in the container.
- Keep a Codex session alive while you leave and return to the Home Assistant sidebar.

It deliberately does **not** request host networking, Docker access, full host
access, or Supervisor-management API access. Optional Home Assistant control
uses the supported internal Core API through a restricted helper.

## Install

[![Add HA Codex repository to Home Assistant](https://my.home-assistant.io/badges/supervisor.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fambient-home-systems%2Fha-codex)

1. Select the button above to open your Home Assistant instance with the HA
   Codex repository URL pre-filled, then add the repository.
2. Open **Settings → Apps → App Store**.
3. Find **HA Codex**, then select **Install** and **Start**.
4. Enable **Show in sidebar**, then open **HA Codex** from the sidebar.

If the button does not open your Home Assistant instance, open the App Store
and use its repository-management option to add:

```text
https://github.com/ambient-home-systems/ha-codex
```

## First sign-in

Open the sidebar item. Codex starts automatically. On first use, HA Codex
shows a three-option sign-in menu. After updating from an earlier version,
restart HA Codex to begin this revised sign-in flow in a fresh session.

1. **Sign in with ChatGPT in a browser:** starts Codex's normal browser sign-in
   flow. If Home Assistant cannot open a browser automatically, Codex shows a
   secure sign-in URL in the terminal. Open that URL in any browser, sign in to
   ChatGPT, then return to HA Codex.
2. **Log in with a different device (Preferred Method):** complete the secure,
   one-time code sign-in from a phone, tablet, or another computer, then return
   to HA Codex. This avoids browser and pop-up limits in the embedded Home
   Assistant page.
3. **OpenAI API key** (only if the Codex sign-in screen offers it): this uses a
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
| **Terminal scrollback** | 5,000 lines | Keeps 1,000–50,000 lines of past terminal output in both the browser and persistent terminal session, including output produced immediately after startup. |
| **Terminal theme** | Dark | Sets the terminal color theme. |
| **Session persistence** | On | Keeps the active Codex session running when you leave HA Codex for another Home Assistant page, then reconnects it when you return. |
| **Preserve terminal history** | On | Keeps the visible browser scrollbar and long inline transcript while the active session persists in the background. Recommended. |
| **Patch compatibility mode** | On | Lets Codex use normal patches on Home Assistant OS, avoiding the nested Bubblewrap restriction that otherwise forces a shell-edit fallback. Command approval behavior is unchanged. |
| **Allow Home Assistant control actions** | Off | Enables HA Codex's restricted configuration check and reload helper. |
| **Allow Home Assistant Core restart** | Off | Allows the helper to restart Core after a successful configuration check. Requires control actions to be enabled. |

For long reviews, leave **Preserve terminal history** on. A visible gold
history rail at the right edge shows your position in the history: use its
up/down buttons, click or drag its track, use a mouse wheel or trackpad, or
swipe inside the terminal on a touch device. The rail navigates the full
configured history buffer even when Home
Assistant hides the browser's native scrollbar.
Raise **Terminal scrollback** only if 5,000 lines is not enough.

### Patches on Home Assistant OS

Leave **Patch compatibility mode** enabled (the default). Home Assistant OS
does not allow the nested unprivileged Bubblewrap namespace Codex normally uses
for patches. Without this mode, Codex may report that its normal patch mechanism
is unavailable before it touches a file and use a shell-edit fallback instead.
Patch compatibility mode uses HA Codex's existing add-on container boundary so
normal patches work without host, Docker, or Supervisor-management access. It
does not change Codex's command-approval behavior. Disable it only when
diagnosing a sandbox-related issue.

### Home Assistant control actions

No separate API key, token, IP address, or host setup is needed. To allow
Codex to validate configuration or reload supported areas, enable **Allow Home
Assistant control actions** and restart HA Codex. To permit a Home Assistant
Core restart, also enable **Allow Home Assistant Core restart**. Both settings
are off by default.

Codex uses the built-in `ha-codex-ha` helper, which can validate configuration,
reload automations, scripts, scenes, groups, templates, Core configuration, or
Lovelace resources, and restart Core only after validation. Codex must explain
the action and request command approval first. The helper cannot control the
host, Docker, Supervisor, updates, shutdown, or arbitrary Home Assistant
services. Refresh the browser after dashboard changes; reloading Lovelace
resources does not reload dashboard YAML or storage configuration by itself.

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
mounted read/write. It cannot control Docker, access the host, or call the
Supervisor-management API. Keep access to your Home Assistant account protected.
