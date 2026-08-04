# Multi-OS chezmoi layout

Apply this repo with chezmoi on **each** environment (Windows native, WSL, native Linux).
`destDir` is that environment's home (`%USERPROFILE%` or `$HOME`).

## What is shared

| Target | Notes |
|--------|--------|
| `~/.cursor/skills/**` | Same relative path on Windows and Linux |
| `~/.agents/skills/**` | Cross-tool agent skills |
| `~/.config/**` (most) | git, starship, atuin, eca, … |

## What differs by OS

| Concern | Mechanism |
|---------|-----------|
| VS Code Insiders settings | Shared body in `.chezmoitemplates/vscode-insiders-settings.json`; Windows → `AppData/Roaming/...`, Linux → `~/.config/...` via `.chezmoiignore` |
| `~/.zshrc`, `~/.proxy.sh` | Ignored on Windows |
| Package bootstrap | `run_once_install-tools.sh.tmpl` (Linux) + `run_once_install-tools.ps1.tmpl` (Windows). Empty template on the wrong OS ⇒ skipped |
| Git remote / SSH helper | Same split: `.sh.tmpl` on Linux, `.ps1.tmpl` on Windows |
| zsh plugins / vscode-remote MCP | Linux-only scripts (empty template ⇒ skipped) |
| `%USERPROFILE%\.wslconfig` | WSL-only `run_onchange_after_*` script writing the **Windows host** file (outside WSL dest) |

## WSL detection (templates)

```text
{{ if eq .chezmoi.os "linux" }}
{{   if (.chezmoi.kernel.osrelease | lower | contains "microsoft") }}
# WSL-only
{{   end }}
{{ end }}
```

Never read `.chezmoi.kernel.*` unguarded on Windows (`missingkey=error`).

## Bootstrap

```bash
# Linux / WSL
./install.sh
# or: chezmoi init --apply git@github.com:caseytomlin/dotfiles.git

# Windows (PowerShell)
winget install twpayne.chezmoi
chezmoi init --apply git@github.com:caseytomlin/dotfiles.git
```

Age key and `~/.config/chezmoi/chezmoi.toml` are per-machine (not in this repo).
