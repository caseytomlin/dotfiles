# Keep PATH consistent whether PowerShell was started from Windows or via WSL/Cursor.
# WSL-launched powershell.exe often inherits a truncated process PATH and misses
# User-scoped WinGet shims (uv, chezmoi, jq, fzf, px, ...).
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")
