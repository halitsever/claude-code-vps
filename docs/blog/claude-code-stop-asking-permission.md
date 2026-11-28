---
title: "How to Make Claude Code Stop Asking for Permission"
titleTemplate: false
description: "Make Claude Code stop asking for permission on commands you trust: allow rules in settings.json, acceptEdits and auto mode, and when bypass is the wrong tool."
date: 2026-11-28
faq:
  - q: "How do I stop Claude Code asking for permission for one command?"
    a: "Choose Yes, and don't ask again on the prompt, or add an allow rule such as Bash(npm run test *) to permissions.allow in a settings file. The prompt option saves the rule to .claude/settings.local.json in that repository."
  - q: "How do I give Claude Code all permissions?"
    a: "Start it with --dangerously-skip-permissions or --permission-mode bypassPermissions. Anthropic recommends that only in isolated containers or VMs; auto mode gives fewer prompts with a classifier still checking actions."
  - q: "Why does Claude Code keep asking for permission after I allowed a command?"
    a: "Rules are checked in the order deny, then ask, then allow, so a matching ask or deny rule wins over your allow rule. A project settings file can also wait for workspace trust. Run /permissions to see every rule and the file it came from."
  - q: "Where are Claude Code permission rules saved?"
    a: "In settings files: ~/.claude/settings.json for you in every project, .claude/settings.json for a shared project, and .claude/settings.local.json for your own rules in one project."
---

# Stop Claude Code asking for permission on commands you trust

<p class="post-meta">Halit Sever · 28 November 2026</p>

Claude Code asks before it runs a shell command, edits a file or fetches a page. That is right for unfamiliar code and tiring for the hundredth `npm test`. You can cut most of the prompts without switching every check off. This post goes from the narrowest fix to the widest, using Anthropic's [permissions](https://code.claude.com/docs/en/permissions) and [permission modes](https://code.claude.com/docs/en/permission-modes) docs.

## 1. "Yes, and don't ask again"

The quickest fix is on the prompt itself. For a Bash command the prompt offers **Yes, and don't ask again for: npm test \***. Pick it and Claude Code saves an allow rule to `.claude/settings.local.json` at the root of the git repository. The rule covers future sessions anywhere in that repository.

For file edits the same option lasts until the session ends. Some prompts show only a one-time **Yes**: Claude Code offers the "don't ask again" options only when the prompt can show everything the saved rule would allow.

## 2. Allow rules in settings.json

To approve commands everywhere, or before Claude ever asks, write the rules yourself. Rules have the form `Tool` or `Tool(specifier)`:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run lint)",
      "Bash(npm run test *)",
      "Bash(git status)",
      "WebFetch(domain:docs.python.org)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)"
    ]
  }
}
```

Put it in `~/.claude/settings.json` to apply in every project on the machine, or in a project's `.claude/settings.json` to share it with the team. The server that claude-code-vps sets up ships a user settings file with two rules of this kind, `Bash(gh pr merge *)` and `Bash(gh repo edit *)`, so the agent can merge and edit repositories without stopping.

A few rules about rules:

- **Order is deny, then ask, then allow.** The first match wins and specificity does not change it. A broad `deny` on `Bash(aws *)` blocks `aws s3 ls` even if you allowed that exact command.
- **A bare tool name matches everything.** `Bash` or `Bash(*)` allows every shell command. As a deny rule, a bare name removes the tool from Claude's view entirely.
- **Lists merge across files.** An allow list in your user file and one in the project file both apply.
- **Settings reload on save.** Edits to `permissions` reach the running session without a restart. `/permissions` shows every rule and which file it came from.

If a rule does not seem to apply, check for an `ask` or `deny` rule that also matches, and check whether the project file is waiting for you to trust the folder. [Claude Code settings.json](/blog/claude-code-settings-json) covers the files and their precedence.

## 3. acceptEdits mode

If the prompts you are tired of are file edits, switch modes instead of writing rules. Press Shift+Tab once from Manual mode, or start with:

```bash
claude --permission-mode acceptEdits
```

Claude can now create and edit files in the working directory without asking, along with common filesystem commands such as `mkdir`, `mv`, `cp` and `sed` on paths inside it. Other shell commands still ask, and so do writes to protected paths. You review the result afterwards with `git diff`.

## 4. auto mode

Auto mode removes routine prompts and puts a classifier model in your place: it reviews actions before they run and blocks the ones that go beyond your request, target infrastructure it does not recognize, or follow instructions from content Claude read.

```bash
claude --permission-mode auto
```

On Claude Code 2.1.283 and later it is the starting mode for interactive sessions when your account and model support it, so you may already be in it. The docs list the supported models and note that an organization can turn it off. To make it your default, set `"defaultMode": "auto"` in `~/.claude/settings.json`. It does not take effect from a project's `.claude/settings.json` or `.claude/settings.local.json`.

Anthropic is explicit that auto mode reduces prompts but does not guarantee safety. Use it when you trust the general direction of the task.

## 5. Bypass: the last step

`--dangerously-skip-permissions` turns the checks off. Allow rules stop mattering, deny and ask rules still apply, and nothing guards against prompt injection. It refuses to run as root. The docs recommend it only in isolated containers or VMs without internet access. The details are in [claude --dangerously-skip-permissions, explained](/blog/claude-dangerously-skip-permissions).

## Which one to use

| You want | Use |
| --- | --- |
| Stop prompts for a few known commands | Allow rules, or "don't ask again" on the prompt |
| Stop prompts for file edits | `acceptEdits` mode |
| Few prompts on a long task, with checks | `auto` mode |
| No prompts in a throwaway container | `bypassPermissions`, as a non-root user |
| An exact allowlist in CI | `claude -p ... --permission-mode dontAsk --allowedTools ...` |

`dontAsk` is the strict one: anything that would prompt is denied, and only pre-approved tools run. It suits scripts where nobody is there to answer.

## On a server

Prompts are the thing that stops an agent while you are away. On a remote machine, an allow list for your build and test commands plus auto mode keeps long tasks moving, and a [Notification hook](/blog/claude-code-notifications) pushes the prompts that remain to your phone so you can answer them over [SSH](/blog/claude-code-ssh).

## FAQ

<Faq />

## Related

- [claude --dangerously-skip-permissions, explained](/blog/claude-dangerously-skip-permissions): what bypass mode skips and what it does not
- [Claude Code settings.json](/blog/claude-code-settings-json): where rules live and which file wins
- [Claude Code notifications](/blog/claude-code-notifications): a phone push when a prompt is waiting
- [Claude Code over SSH](/blog/claude-code-ssh): reaching the session from anywhere
