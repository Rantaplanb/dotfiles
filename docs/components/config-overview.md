# Config Overview

Summary of notable config areas managed by chezmoi, with links to dedicated docs for larger components.

**Source:** `private_dot_config/` -> `~/.config/`, `private_dot_codex/` -> `~/.codex/`, `dot_claude/` -> `~/.claude/`, `private_dot_local/private_share/` -> `~/.local/share/`

## Managed Components

| Component | Source Path | Dedicated Doc | Description |
|---|---|---|---|
| **Codex** | `private_dot_codex/` | -- | OpenAI Codex CLI defaults, including full-access/no-approval mode |
| **Claude Skills** | `dot_claude/symlink_skills` | -- | Symlink to the separate `~/.agents/skills` Git repository; skill contents are not managed by dotfiles |
| **OpenCode** | `private_dot_config/opencode/` | [opencode.md](opencode.md) | Primary AI CLI profile with agents, commands, and skills |
| **Karabiner** | `private_dot_config/private_karabiner/` | [karabiner.md](karabiner.md) | Keyboard remapping (generated config) |
| **Carapace** | `private_dot_config/carapace/` | [carapace.md](carapace.md) | Shell completion framework |
| **Zsh** | `private_dot_config/zsh/`, `dot_zshenv.tmpl` | [zsh.md](zsh.md) | Shell bootstrap plus XDG-aware tool/runtime environment |
| VS Code | `private_Library/Application Support/Code/User/private_settings.json.tmpl` | -- | Integrated terminal profile pinned to dotfiles-managed `zsh` |
| **Atuin** | `private_dot_config/private_atuin/private_config.toml` | -- | Shell history search, sync, and AI settings |
| Terraform CLI | `private_dot_config/terraform/terraform.rc` | -- | CLI defaults (for example checkpoint suppression) |
| **NeoMutt** | `private_dot_config/neomutt/` | [email.md](email.md) | Terminal mail client config and custom mailbox bindings |
| **notmuch** | `private_dot_config/notmuch/default/` | [email.md](email.md) | Mail index/search config and tagging hook |
| **msmtp** | `private_dot_config/msmtp/private_config.tmpl` | [email.md](email.md) | SMTP account config rendered from Bitwarden secrets |
| **isync (mbsync)** | `private_dot_config/isyncrc.tmpl` | [email.md](email.md) | IMAP sync channels and Maildir mapping |
| **abook** | `private_dot_config/abook/`, `private_dot_local/private_share/abook/` | [email.md](email.md) | Local address book split across XDG config/data paths |
| Mise | `private_dot_config/mise/` | -- | Tool/version manager config (`linear-cli` via the cargo backend) |
| Ghostty | `private_dot_config/ghostty/` | -- | Terminal emulator |
| tmux | `private_dot_config/tmux/` | -- | Terminal multiplexer |
| Starship | `private_dot_config/starship.toml` | -- | Prompt theme |
| Git | `private_dot_config/git/` | -- | Git config and work profile |
| Bat | `private_dot_config/bat/` | -- | Cat replacement with syntax highlighting |
| Yazi | `private_dot_config/yazi/` | -- | Terminal file manager |
| Lazygit | `private_dot_config/lazygit/` | -- | Git TUI |
| Brew | `private_dot_config/brew/` | -- | Homebrew Brewfile |
| Aerospace | `private_dot_config/aerospace/` | -- | macOS window manager (Darwin only) |
| Finicky | `private_dot_config/finicky/` | -- | macOS browser routing (Darwin only) |
| SketchyBar | `private_dot_config/sketchybar/` | -- | macOS status bar (Darwin only) |
| Raycast | `private_dot_config/raycast/` | -- | macOS launcher (partial, extensions ignored) |
| Diffnav | `private_dot_config/diffnav/` | -- | Git diff TUI pager (file tree + delta rendering) |
| gh-dash | `private_dot_config/gh-dash/` | -- | GitHub dashboard TUI (`gh` extension, Catppuccin Mocha Mauve) |

## Ghostty

Terminal emulator. Key configuration areas:

- **Theme:** Catppuccin Mocha, 80% background opacity with blur
- **Font:** JetBrainsMono Nerd Font Mono, size 21, ligatures enabled
- **Cursor:** Block with blink, hidden while typing
- **macOS:** Option-as-alt, hidden titlebar, global quick terminal (`Cmd+Ctrl+T`)
- **Keybindings:** Splits, tab management, Dvorak-layout pane navigation, CSI sequences for zsh integration

Custom keybindings are documented in [shortcuts.md](../shortcuts.md).

_Reference: `private_dot_config/ghostty/config:1`_

## tmux

Terminal multiplexer with Catppuccin theme and plugin ecosystem.

- **Prefix:** `Ctrl-a`
- **Plugins (TPM):** vim-tmux-navigator, catppuccin, tmux-smooth-scroll, tmux-yank, tmux-resurrect, tmux-continuum, tmux-floax, tmux-harpoon
- **Plugin bootstrap:** `chezmoi apply` installs TPM plugins idempotently via `.chezmoiscripts/run_after_04-tmux-plugins.sh.tmpl`
- **Session picker:** `prefix + s` opens a `sesh` + `gum` popup helper
- **AI split:** `prefix + o` opens Codex in a horizontal split rooted at the current pane path
- **Session persistence:** Resurrect + Continuum (auto-save every 15min, restore on start)
- **Status line:** Top position, oasis-style mode indicator with per-mode colors/icons
- **History:** 100,000 lines, mouse enabled, base-index 1

Custom keybindings are documented in [shortcuts.md](../shortcuts.md).

_Reference: `private_dot_config/tmux/tmux.conf:1`_

## Codex

OpenAI Codex CLI config is managed as a chezmoi modify script so project trust,
plugin, and marketplace runtime state can remain in `~/.codex/config.toml`.
Personal shared skills, including `secrets-vault`, live in the separate Git repository at `~/.agents/skills`.
Dotfiles does not deploy or delete that repository's contents.

- **Approval policy:** `never`
- **Sandbox mode:** `danger-full-access`
- **Notice:** full-access warning acknowledgement is preserved as `true`

_Reference: `private_dot_codex/modify_private_config.toml.tmpl:1`_

## sesh

Standalone tmux session manager used by the `prefix + s` popup helper.

- **Config:** `~/.config/sesh/sesh.toml`
- **Defaults:** two-part session names, separator-aware matching, `main` hidden from picker results

_Reference: `private_dot_config/sesh/sesh.toml:1`_

## Git

Git configuration for the sanitized baseline:

- Base config at `~/.config/git/config`
- `git push` auto-sets upstream on the first push of a new branch via `push.autoSetupRemote = true`
- Uses diffnav as `git diff`/`git show` pager (TUI with file tree, powered by delta underneath)
- Delta remains as `core.pager` for non-diff git output (log, blame) and as interactive diffFilter
- Catppuccin Mocha theme via delta's `[delta]` config section

_Reference: `private_dot_config/git/`_

## Brew

Homebrew Brewfile at `~/.config/brew/Brewfile`. Managed by the lifecycle script `02-install-packages` which runs `brew bundle` when the Brewfile content changes. The bootstrap pre-taps third-party repos declared in the Brewfile and validates every formula/cask before install so a fresh-machine apply fails clearly instead of silently drifting when an upstream tap package changes.

The Brewfile intentionally excludes personal taps, AWS wrapper tooling, and
work-specific GitLab CLI config from the `lpersonal` baseline.

_Reference: `private_dot_config/brew/Brewfile`_

## References

- OpenCode README: `private_dot_config/opencode/README.md:1`
- Email stack doc: `docs/components/email.md:1`
- mbsync template: `private_dot_config/isyncrc.tmpl:1`
- Ghostty config: `private_dot_config/ghostty/config:1`
- tmux config: `private_dot_config/tmux/tmux.conf:1`
- Key paths table: `AGENTS.md:80`
