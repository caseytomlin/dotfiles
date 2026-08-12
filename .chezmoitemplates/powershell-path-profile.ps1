# Keep PATH consistent whether PowerShell was started from Windows or via WSL/Cursor.
# WSL-launched powershell.exe often inherits a truncated process PATH and misses
# User-scoped WinGet shims (uv, chezmoi, jq, fzf, px, ...).
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

# NTLM proxy bridge for WSL -> Tanium Trusted IP egress (Netskope / Bayer).
# Mode A (default): empty upstream so Windows/Netskope dials like the browser.
# Prefer WSL mirrored networking (127.0.0.1). Bind 0.0.0.0 so NAT + host firewall
# can reach Windows:3128 from the WSL default gateway until mirrored is active.
function Test-PxBridge {
  try {
    $c = New-Object System.Net.Sockets.TcpClient
    $iar = $c.BeginConnect('127.0.0.1', 3128, $null, $null)
    $ok = $iar.AsyncWaitHandle.WaitOne(500)
    if ($ok -and $c.Connected) { $c.Close(); return $true }
    $c.Close()
  } catch {}
  return $false
}

function Get-PxIniPath {
  $px = Get-Command px -ErrorAction SilentlyContinue
  if (-not $px) { return $null }
  $dir = Split-Path -Parent $px.Source
  $ini = Join-Path $dir 'px.ini'
  if (Test-Path -LiteralPath $ini) { return $ini }
  return $null
}

function Ensure-PxModeA {
  # Clear McAfee upstream so Tanium uses Netskope (browser-equivalent) egress.
  $ini = Get-PxIniPath
  if (-not $ini) { return }
  $raw = Get-Content -LiteralPath $ini -Raw
  if ($raw -notmatch '(?im)^\s*server\s*=') { return }
  if ($raw -match '(?im)^\s*server\s*=\s*$') { return }
  if ($raw -match '(?im)^\s*server\s*=\s*\S+') {
    Copy-Item -LiteralPath $ini -Destination ($ini + '.bak-before-mode-a') -Force
    $updated = [regex]::Replace($raw, '(?im)^(\s*server\s*=\s*).*$', '${1}')
    Set-Content -LiteralPath $ini -Value $updated -NoNewline
    Write-Host "px-bridge: cleared px.ini upstream (Mode A / Netskope). Backup: $ini.bak-before-mode-a"
  }
}

function Start-PxBridge {
  if (Test-PxBridge) {
    Write-Host "px-bridge: already listening on :3128"
    return
  }
  $px = Get-Command px -ErrorAction SilentlyContinue
  if (-not $px) {
    Write-Host "px-bridge: 'px' not on PATH. Install: winget install genotrance.px   (or: pip install --user px-proxy)"
    return
  }
  Ensure-PxModeA
  # gateway=1 binds all ifaces; hostonly=0 so WSL NAT guest IPs are allowed (not just host NICs).
  # allow=192.168.0.0/16 covers Hyper-V NAT; firewall must still permit inbound TCP 3128.
  # Do NOT pass --proxy=10.185... here (Mode B); that breaks Tanium off-VPN.
  Start-Process -FilePath $px.Source -ArgumentList @(
    '--gateway=1', '--hostonly=0', '--port=3128',
    '--allow=192.168.0.0/16,127.0.0.1'
  ) -WindowStyle Hidden
  Start-Sleep -Milliseconds 800
  if (Test-PxBridge) {
    Write-Host "px-bridge: started on :3128 (Mode A; gateway; WSL NAT OK)"
  } else {
    Write-Host "px-bridge: start attempted but port 3128 not open yet - check Task Manager for px"
  }
}

Set-Alias -Name px-bridge -Value Start-PxBridge
