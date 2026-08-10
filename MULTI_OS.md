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
| PowerShell PATH (Windows) | `run_onchange_after_powershell-path.ps1.tmpl` writes PATH-sync `profile.ps1` under **MyDocuments** (`WindowsPowerShell` + `PowerShell`) so WSL-launched and native PS see the same User/Machine PATH (uv, chezmoi, WinGet shims). Body: `.chezmoitemplates/powershell-path-profile.ps1` |
| Git remote / SSH helper | Same split: `.sh.tmpl` on Linux, `.ps1.tmpl` on Windows |
| zsh plugins / vscode-remote MCP | Linux-only scripts (empty template ⇒ skipped) |
| `%USERPROFILE%\.wslconfig` | WSL-only `run_onchange_after_*` script writing the **Windows host** file (outside WSL dest); keeps `autoProxy=false` + mirrored networking |
| Windows `px` bridge | `run_once_install-px.ps1` + `Start-PxBridge` in PowerShell profile; WSL helper `~/.local/bin/px-bridge`. `~/.proxy.sh` prefers `:3128` (localhost if mirrored, else default-gateway) for Tanium Trusted IPs |

### Activate WSL → px (Tanium Trusted IPs)

`.wslconfig` alone does nothing until WSL is fully restarted. Prefer mirrored:

```powershell
# From elevated OR normal Windows PowerShell (closes all WSL distros):
wsl --shutdown
# Reopen WSL / Cursor, then in WSL:
px-bridge
proxy-recheck
proxy-info
curl -sS https://api.ipify.org   # want Netskope/Bayer, not home ISP
```

If you must stay on NAT (`eth0` is `192.168.x`):

1. `Start-PxBridge` uses `--gateway=1 --hostonly=0 --allow=192.168.0.0/16,127.0.0.1`
   (`hostonly=1` rejects WSL NAT client IPs → CONNECT abort).
2. **Elevated** Windows PowerShell (admin):

```powershell
New-NetFirewallRule -DisplayName "WSL px bridge 3128" -Direction Inbound -Protocol TCP -LocalPort 3128 -Action Allow -Profile Any
```

3. In WSL, `proxy-recheck` should pick `<gateway>:3128`.

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
