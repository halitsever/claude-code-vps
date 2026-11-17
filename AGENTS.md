# AGENTS.md

claude-code-vps (`claude-vps`) is a Bash tool that sets up a fresh Ubuntu server as a remote Claude Code workstation and keeps its KDE and Claude Code config in sync. Developers run it on their own VPS.

## Verify a change

- No CI runs on pull requests. Before pushing, run `bash tests/run.sh`. It runs every `tests/test_*.sh` in its own shell.
- Run `shellcheck -x -S warning` on the files you touched. The tree has a few existing warnings, so compare against `main` rather than expecting zero.
- Setup steps (`lib/setup.sh`) are only exercised on a real server. Try `sudo claude-vps setup --dry-run` there, then a fresh Ubuntu 24.04 or 26.04 VPS for a full run.
- Docs: `cd docs && npm ci && npm run build` (Node 22). The site base is `/claude-code-vps/`.

## Gotchas

- `dotfiles/home/` is the owner's real config. Every server applies it on `claude-vps sync` or autosync, so an edit there reaches all servers. `claude-vps capture` rewrites it from the local machine.
- Captured files have `$HOME` replaced with `@HOME@`. Keep the placeholder when editing them.
- `dotfiles/home/.claude/settings.json` and its hooks are shipped to servers. They do not configure an agent working in this repo.
- `dotfiles/seed/` files are copied only when the target does not exist yet. `dotfiles/seed/.claude/CLAUDE.md` is intentionally empty.
- Binary files are never captured, and the paths in `~/.config/claude-vps/local-only` are never touched by `apply`.
- `apply` skips paths in the `local-only` list and, after it changes files, runs every executable in `~/.config/claude-vps/post-apply.d/`. These are the public extension points for add-ons such as HaltOS. Keep them generic and backwards compatible, and keep add-on specific code out of this repo: add-ons depend on claude-code-vps, never the other way round.
- Re-running setup must leave a working server alone: it does not restart xrdp or reload SSH when nothing changed, so open RDP sessions stay up. `sudo claude-vps update` re-runs setup with the options saved in `/etc/claude-vps.conf`.
- Pushing a `v*` tag publishes a GitHub Release. The tag must match `VERSION`, and `CHANGELOG.md` needs a non-empty `## X.Y.Z` section. `claude-vps release X.Y.Z` (owner only) checks the changelog, commits a `VERSION` bump if needed, tags, and pushes `HEAD` along with the tag.
- The docs workflow checks out full history (`fetch-depth: 0`) because VitePress `lastUpdated` reads git.

## Conventions

- Commit subjects use conventional-commit style, in English, with no body or trailer.
- Work on a branch and open a PR. The owner merges.
- Don't add emoji to new text. Code comments are short, one line where possible, and explain why.
- The README follows the owner's template. Leave every image from `halitsever-api.vercel.app` byte-for-byte as it is. Only the `title=` value of `api/repo-title` and the issue wrapper link may be corrected.
- The owner bumps `VERSION` and releases. Add user-facing changes under `## Unreleased` in `CHANGELOG.md`.

## Docs site

- The VitePress site lives in `docs/`, has its own `package.json` and lockfile, and deploys to https://halitsever.github.io/claude-code-vps/ from `.github/workflows/docs.yml` on pushes to `main` that touch `docs/`.
- It is in 11 languages: English at the root plus `de`, `es`, `fr`, `it`, `ja`, `ko`, `pt`, `ru`, `tr` and `zh`. Each language has its own copy of every page, and the landing page strings are in `docs/.vitepress/theme/i18n/`. A content change belongs in every language.
- `docs/.vitepress/config.mts` builds the canonical, hreflang, Open Graph and JSON-LD tags. A new page goes into its `PAGES` list and into `docs/public/llms.txt`.
