---
title: "How to Update Claude Code (Native, npm, apt, Homebrew)"
titleTemplate: false
description: "Update Claude Code with claude update, npm, apt, dnf or Homebrew. How auto-updates work, how to pick the stable channel, pin a version or turn updates off."
date: 2026-11-28
faq:
  - q: "How do I update Claude Code?"
    a: "Run claude update. On the native install it downloads the newest version for your release channel; on Homebrew, WinGet or Linux package manager installs it goes through that package manager. New versions take effect the next time you start claude."
  - q: "Does Claude Code update itself?"
    a: "The native install does. It checks on startup and while running, installs in the background and switches on the next start. Homebrew, WinGet, apt, dnf and apk installs do not update by default."
  - q: "How do I update Claude Code installed with npm?"
    a: "Run npm install -g @anthropic-ai/claude-code@latest. Anthropic advises against npm update -g, which keeps to the version range of the original install and may not reach the newest release."
  - q: "How do I disable Claude Code auto-updates?"
    a: "Set DISABLE_AUTOUPDATER to 1 in the env block of settings.json. That stops the background check but claude update still works. DISABLE_UPDATES blocks every update path."
---

# How to update Claude Code

<p class="post-meta">Halit Sever · 28 November 2026</p>

Claude Code ships new versions often, and some features in the docs need a recent one. How you update depends on how you installed it. This post covers each install method, the release channels, and how to hold a version still. The commands come from Anthropic's [setup docs](https://code.claude.com/docs/en/setup#update-claude-code) and `claude --help` on version 2.1.326.

## Check your version first

```bash
claude --version
```

`claude doctor` shows more: the install method, whether auto-updates are on, and the result of the last update attempt.

## Native install: claude update

If you installed with `curl -fsSL https://claude.ai/install.sh | bash` (or the PowerShell and CMD equivalents on Windows), run:

```bash
claude update
```

`claude upgrade` is an alias. When an update installs, the command prints a line ending in `to version <new version>`. If you are already current it says `Claude Code is up to date (<version>)`.

You rarely need to, though. The native install checks for updates on startup and periodically while it runs, downloads them in the background, and uses the new version the next time you start `claude`. A session that is already running keeps its version until you restart it.

On macOS and Linux the launcher is `~/.local/bin/claude`, a symlink into `~/.local/share/claude/versions/`. If you replace that symlink with your own script, updates still install but you keep running whatever your script starts.

## npm

```bash
npm install -g @anthropic-ai/claude-code@latest
```

Anthropic warns against `npm update -g` here: it respects the version range from the original install and may not move you to the newest release. If the global npm directory is not writable, Claude Code shows a notice at startup and `claude doctor` lists fixes.

## apt, dnf and apk

Installs from Anthropic's Linux package repositories never update themselves, because the upgrade needs root:

```bash
# Debian, Ubuntu
sudo apt update && sudo apt upgrade claude-code
# Fedora, RHEL
sudo dnf upgrade claude-code
# Alpine
apk update && apk upgrade claude-code
```

Each repository has a `stable` and a `latest` channel, chosen by the repository URL. See [How to install Claude Code on Linux](/blog/install-claude-code-linux) for the repository setup.

## Homebrew and WinGet

```bash
brew upgrade claude-code          # or claude-code@latest
winget upgrade Anthropic.ClaudeCode
```

The `claude-code` cask tracks the stable channel and `claude-code@latest` tracks latest. These installs do not auto-update by default. Setting the environment variable `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE=1` lets Claude Code run the upgrade for you in the background. Run `brew cleanup` now and then, since Homebrew keeps old versions on disk.

## Stable or latest

The native install follows a release channel:

- `latest`, the default, gets every release as soon as it ships.
- `stable` gets a version that is usually about a week old and skips releases with major regressions.

Switch in `/config` under **Auto-update channel**, or in `~/.claude/settings.json`:

```json
{
  "autoUpdatesChannel": "stable"
}
```

Moving to stable can mean a downgrade if your current version is newer. To avoid that, pin a minimum in the same edit. Background updates and `claude update` refuse to go below it:

```json
{
  "autoUpdatesChannel": "stable",
  "minimumVersion": "2.1.326"
}
```

One catch: a newly launched model can need a version newer than stable serves. In that case switch back to latest.

## Turn auto-updates off

```json
{
  "env": {
    "DISABLE_AUTOUPDATER": "1"
  }
}
```

This stops the background check only. `claude update` still works when you choose to run it, and `claude doctor` should now show `disabled (set by env: DISABLE_AUTOUPDATER)` on its Auto-updates line. To block every update path, manual ones included, set `DISABLE_UPDATES` instead. That is meant for teams that ship Claude Code through their own tooling.

## Install a specific version

The native installer takes a channel or a version number:

```bash
curl -fsSL https://claude.ai/install.sh | bash -s stable
curl -fsSL https://claude.ai/install.sh | bash -s 2.1.89
```

`claude install <target>` does the same from an existing install. The channel you install with becomes your default for auto-updates.

## On a server

claude-code-vps uses the native installer for the server user, so the server's Claude Code updates itself like a laptop install. Two habits help on a machine that runs for weeks:

- **Restart long sessions now and then.** A session that has been open in [tmux](https://projects.halit.org/claudegrid/guide/tmux) for days is still on the version it started with. Detach, exit, start again with `claude --continue`.
- **Keep the server itself current.** `sudo claude-vps update` re-runs setup with your saved options, and a running server is left alone when nothing changed. Ubuntu packages come through unattended upgrades, which setup turns on.

If several people or scripts depend on one version, pin it with `minimumVersion` on the stable channel rather than turning updates off entirely.

## FAQ

<Faq />

## Related

- [How to install Claude Code on Linux](/blog/install-claude-code-linux): every install method, including apt and dnf
- [Claude Code settings.json](/blog/claude-code-settings-json): where `autoUpdatesChannel` and `env` go
- [Resume a Claude Code session](/blog/claude-code-resume-session): pick up where you left off after a restart
- [CLI reference](/reference/cli): `claude-vps update` and the other server commands
