---
title: "claude --dangerously-skip-permissions, Explained"
titleTemplate: false
description: "What claude --dangerously-skip-permissions does, what still asks for approval, why it refuses to run as root, and where it is reasonable to use it."
date: 2026-11-28
faq:
  - q: "What does claude --dangerously-skip-permissions do?"
    a: "It starts Claude Code in bypassPermissions mode. Tool calls run without a permission prompt, including writes to protected paths such as .git and .claude. It is the same as claude --permission-mode bypassPermissions."
  - q: "Does --dangerously-skip-permissions skip every prompt?"
    a: "No. Deny rules still block, explicit ask rules still prompt, and removals of critical paths such as your home directory are still checked. In a claude -p run those prompts become denials."
  - q: "Why does it say it cannot be used with root/sudo privileges?"
    a: "On Linux and macOS Claude Code refuses bypassPermissions when it runs as root or under sudo, unless it detects a recognized sandbox. Run it as a normal user, or inside a dev container that uses a non-root user."
  - q: "Is there a safer way to get fewer prompts?"
    a: "Yes. Allow rules in settings.json pre-approve the commands you trust, acceptEdits mode accepts file edits, and auto mode lets a classifier review actions instead of you. Anthropic suggests auto mode over bypassPermissions when you want fewer prompts with safety checks."
---

# What claude --dangerously-skip-permissions really skips

<p class="post-meta">Halit Sever · 28 November 2026</p>

`--dangerously-skip-permissions` is the flag people reach for after the tenth "Do you want to proceed?" prompt. It does what the name says, with a few exceptions that matter, and the name is honest about the risk. This post covers what the flag changes, what it leaves in place, the root error you may hit on a server, and where it makes sense to use it. Facts come from Anthropic's [permission modes](https://code.claude.com/docs/en/permission-modes) page and `claude --help` on Claude Code 2.1.326.

## What the flag does

Claude Code has several permission modes. The flag starts a session in the one called `bypassPermissions`:

```bash
claude --dangerously-skip-permissions
# same thing:
claude --permission-mode bypassPermissions
```

In this mode tool calls run straight away. Shell commands, file edits and web fetches no longer stop for approval, and that includes writes to protected paths such as `.git` and `.claude`, which other modes still ask about.

`claude --help` describes it in one line: "Bypass all permission checks. Recommended only for sandboxes with no internet access."

The first time you start an interactive session this way, Claude Code shows a warning that asks you to accept responsibility. Accepting writes `"skipDangerousModePermissionPrompt": true` into `~/.claude/settings.json`, and later sessions skip the dialog. Declining exits.

## What still asks

"Skip all permissions" is not quite literal. In bypass mode:

- **Deny rules still block.** A `permissions.deny` entry applies in every mode. Allow rules, on the other hand, have no effect here, since everything is already allowed.
- **Ask rules still prompt.** A rule like `"ask": ["Bash(git push *)"]` in your settings keeps working.
- **Critical-path removals are checked.** `rm` and `rmdir` aimed at the filesystem root, a top-level directory such as `/usr`, your home directory or your working directory still stop. Some of these are denied in every mode without asking.
- **Questions stay questions.** Tools that need you, such as Claude asking a multiple-choice question, still wait for an answer.

In a `claude -p` run there is nobody to answer, so the few calls that would still prompt are denied instead.

What it does not give you is any protection against prompt injection. If a web page or a file Claude reads tells it to do something, nothing stands between that instruction and your shell.

## Turning it on without starting in it

You cannot switch an ordinary session into bypass mode with Shift+Tab. It has to be allowed at launch. If you want it available but not active, use the sibling flag:

```bash
claude --allow-dangerously-skip-permissions
```

The session starts in your normal mode, and `bypassPermissions` joins the Shift+Tab cycle for when you want it. To make it the default, set `permissions.defaultMode` to `"bypassPermissions"` in a settings file.

For a one-off unattended run, the docs pair it with print mode:

```bash
claude -p "run the tests and fix what fails" --dangerously-skip-permissions
```

## "cannot be used with root/sudo privileges"

On a fresh VPS you are often logged in as root, and this is what you will see:

```text
--dangerously-skip-permissions cannot be used with root/sudo privileges for security reasons
```

On Linux and macOS, Claude Code refuses bypass mode as root or under `sudo`. The check is skipped only inside a sandbox it recognizes. The fix is not to work around the check but to run Claude Code as a normal user. claude-code-vps creates one for this reason: setup adds a user with `adduser`, puts it in the `sudo` group, and installs Claude Code into that user's `~/.local/bin`, so `claude` never runs as root. If you build a server by hand, the [manual VPS guide](/guide/claude-code-vps) does the same.

## Where it is reasonable to use

Anthropic's advice is clear: only in isolated environments such as containers, VMs or dev containers without internet access, where Claude Code cannot damage your host.

A VPS is a separate machine, so it keeps the agent away from your laptop's files, keys and browser sessions. Be honest about what it is not, though:

- It has internet access, so it does not meet the "no internet" part of the advice.
- Whatever you log in to on the server is in reach. On a claude-code-vps server that usually means `gh` with your GitHub token, and the user is in the `docker` group, which is root-equivalent on that box.
- A mistake still costs you the server's state, even if your laptop is fine.

If you do use bypass mode on a server, scope what it can reach: a fine-grained GitHub token limited to the repositories you work on, no production credentials on the box, and a snapshot or backup you can roll back to. For full isolation, Anthropic's [dev container](https://code.claude.com/docs/en/devcontainer) setup runs Claude Code as a non-root user behind a firewall that only allows the domains it needs.

## Fewer prompts without bypass

Most of the time the goal is "stop asking about `npm test`", not "never ask about anything". Three options sit between the default and bypass:

| Option | What it does |
| --- | --- |
| Allow rules | `permissions.allow` in `settings.json` pre-approves named commands, such as `"Bash(npm run test *)"` |
| `acceptEdits` mode | Accepts file edits and common filesystem commands in the working directory |
| `auto` mode | A background classifier reviews actions instead of you |

The docs recommend auto mode over bypass when you want fewer prompts but still want safety checks. [How to make Claude Code stop asking for permission](/blog/claude-code-stop-asking-permission) walks through each one, and [Claude Code settings.json](/blog/claude-code-settings-json) covers where the rules live.

## FAQ

<Faq />

## Related

- [How to make Claude Code stop asking for permission](/blog/claude-code-stop-asking-permission): allow rules and the safer modes
- [Claude Code settings.json](/blog/claude-code-settings-json): the four settings files and which one wins
- [Claude Code over SSH](/blog/claude-code-ssh): a server setup with key-only login
- [What gets installed](/guide/what-it-installs): the user, groups and tools claude-code-vps sets up
