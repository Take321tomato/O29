<#
  export-codex.ps1
  Makes a SAFE copy of %USERPROFILE%\.codex for migration to Claude Code.
  - Copies only an allow-list of items (never auth.json / credentials).
  - Masks secret-looking values in config.toml.
  - Session logs are NOT copied unless -IncludeHistory is given
    (and even then, known token patterns are masked best-effort).
  Nothing is uploaded anywhere; output stays on this PC.

  Usage (PowerShell):
    powershell -ExecutionPolicy Bypass -File .\export-codex.ps1
    powershell -ExecutionPolicy Bypass -File .\export-codex.ps1 -IncludeHistory
#>
param(
  [string]$Source = (Join-Path $env:USERPROFILE ".codex"),
  [string]$Dest   = (Join-Path $env:USERPROFILE "codex-export"),
  [switch]$IncludeHistory
)
$ErrorActionPreference = "Stop"

if (-not (Test-Path $Source)) { throw "Not found: $Source" }
if (Test-Path $Dest) { throw "Already exists: $Dest (delete or rename it first)" }
New-Item -ItemType Directory -Path $Dest | Out-Null

# Patterns of secrets to mask in any copied text file
$secretPatterns = @(
  'sk-[A-Za-z0-9_\-]{16,}',          # OpenAI / Anthropic style keys
  'gh[pousr]_[A-Za-z0-9]{20,}',      # GitHub tokens
  'github_pat_[A-Za-z0-9_]{20,}',
  'AKIA[0-9A-Z]{16}',                # AWS access key id
  'xox[abprs]-[A-Za-z0-9\-]{10,}',   # Slack tokens
  'AIza[0-9A-Za-z_\-]{30,}',         # Google API keys
  '(?i)bearer\s+[A-Za-z0-9\._\-]{16,}',
  'eyJ[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}'  # JWT
)
function Protect-Text([string]$text) {
  foreach ($p in $secretPatterns) { $text = [regex]::Replace($text, $p, '<REDACTED>') }
  return $text
}
function Copy-Masked([string]$from, [string]$to) {
  $dir = Split-Path $to -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  $text = [System.IO.File]::ReadAllText($from)
  [System.IO.File]::WriteAllText($to, (Protect-Text $text))
}
function Copy-TreeMasked([string]$name) {
  $src = Join-Path $Source $name
  if (-not (Test-Path $src)) { return }
  Get-ChildItem -Path $src -Recurse -File | ForEach-Object {
    if ($_.Name -match '(?i)^(auth\.json|.*\.(pem|key|p12|pfx)|\.env.*)$') { return }
    $rel = $_.FullName.Substring($Source.Length).TrimStart('\')
    Copy-Masked $_.FullName (Join-Path $Dest $rel)
  }
  Write-Host "copied: $name"
}

# 1) Inventory: file names and sizes only (no contents)
Get-ChildItem -Path $Source -Recurse -Force -File |
  Select-Object @{n='Path';e={$_.FullName.Substring($Source.Length).TrimStart('\')}}, Length, LastWriteTime |
  Export-Csv -Path (Join-Path $Dest "_inventory.csv") -NoTypeInformation -Encoding UTF8
Write-Host "wrote: _inventory.csv"

# 2) Instructions, custom prompts, skills, rules
foreach ($f in @("AGENTS.md", "AGENTS.override.md")) {
  $p = Join-Path $Source $f
  if (Test-Path $p) { Copy-Masked $p (Join-Path $Dest $f); Write-Host "copied: $f" }
}
foreach ($d in @("prompts", "skills", "rules")) { Copy-TreeMasked $d }

# 3) config.toml with secret-looking values masked
$cfg = Join-Path $Source "config.toml"
if (Test-Path $cfg) {
  $lines = Get-Content $cfg | ForEach-Object {
    if ($_ -match '^\s*[^#=]*(?i:key|token|secret|passw|auth|credential|cookie)[^=]*=') {
      ($_ -replace '=.*$', '= "<REDACTED>"')
    } else { Protect-Text $_ }
  }
  Set-Content -Path (Join-Path $Dest "config.toml") -Value $lines -Encoding UTF8
  Write-Host "copied (masked): config.toml"
}

# 4) Optional: conversation history / session logs (masked best-effort)
if ($IncludeHistory) {
  $h = Join-Path $Source "history.jsonl"
  if (Test-Path $h) { Copy-Masked $h (Join-Path $Dest "history.jsonl"); Write-Host "copied (masked): history.jsonl" }
  Copy-TreeMasked "sessions"
}

Write-Host ""
Write-Host "Done -> $Dest"
Write-Host "auth.json and credentials were NOT copied."
Write-Host "Please open the folder and check for any remaining secrets before sharing it."
