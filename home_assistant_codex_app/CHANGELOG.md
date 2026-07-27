# Changelog

All notable changes to HA Codex are documented here.

## 0.1.12

- Made the recommended **Log in with a different device** sign-in path prominent in both READMEs.

## 0.1.11

- Added an always-visible, touch-draggable terminal scrollbar for reviewing long Codex responses in Home Assistant.
- Kept the browser's native scrollbar available as well, where the device shows it.

## 0.1.10

- Added Preserve terminal history, which starts Codex in inline transcript mode so long reviews can be scrolled in Home Assistant.
- Reduced the default terminal history buffer to 10,000 lines for a better browser-memory balance.
- Documented every add-on setting in the repository and add-on READMEs.

## 0.1.9

- Increased the terminal history buffer to 20,000 lines so long Codex reviews remain scrollable.
- Added a configurable Terminal scrollback setting (1,000–50,000 lines).

## 0.1.8

- Updated the repository URL to `ambient-home-systems/ha-codex` after the repository rename.
- Replaced the illustrated README images with a privacy-safe, real HA Codex workspace screenshot.

## 0.1.7

- Changed the default Codex model to GPT-5.6 Terra to better balance everyday Home Assistant work and usage.
- Added an add-on setting to choose GPT-5.6 Terra or GPT-5.6 Sol before startup.

## 0.1.6

- Added a full repository setup guide with sign-in options, visual examples, safety guidance, and troubleshooting notes.

## 0.1.5

- Reworked the app icon and logo with a high-contrast badge that is clear in both light and dark Home Assistant themes.

## 0.1.4

- Added Bubblewrap to remove Codex's bundled-sandbox warning at startup.

## 0.1.3

- Renamed the visible app and sidebar label to **HA Codex**.

## 0.1.2

- Added the Home Assistant app icon and logo.
- Added this changelog so update details are visible before installation.

## 0.1.1

- Fixed Codex not being found after the app started.
- Separated Codex's installed program files from its persistent login and settings directory.

## 0.1.0

- Initial release with a persistent Codex terminal in the Home Assistant sidebar.
