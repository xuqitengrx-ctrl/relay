# Install relay skills into Claude Code's user-global skills directory.
# Idempotent: re-running upgrades the skills to the current repo state.

$ErrorActionPreference = "Stop"

$RepoDir = Split-Path -Parent $PSScriptRoot
$SkillsSrc = Join-Path $RepoDir "skills"
$SkillsDst = Join-Path $env:USERPROFILE ".claude\skills"

if (-not (Test-Path $SkillsSrc)) {
  Write-Error "Skills source not found at $SkillsSrc. Run this script from a clone of the relay repo."
  exit 1
}

New-Item -ItemType Directory -Force -Path $SkillsDst | Out-Null

foreach ($skill in @("relay-scaffold", "relay-end", "relay-start")) {
  $src = Join-Path $SkillsSrc $skill
  $dst = Join-Path $SkillsDst $skill
  if (Test-Path $dst) {
    Write-Host "Updating $skill (existing skill at $dst)"
  } else {
    Write-Host "Installing $skill -> $dst"
  }
  New-Item -ItemType Directory -Force -Path $dst | Out-Null
  Copy-Item -Path (Join-Path $src "SKILL.md") -Destination (Join-Path $dst "SKILL.md") -Force
}

Write-Host ""
Write-Host "Done. Three skills installed under $SkillsDst:"
Write-Host "  - /relay-scaffold (one-time per project)"
Write-Host "  - /relay-start    (each fresh session)"
Write-Host "  - /relay-end      (each end-of-session)"
Write-Host ""
Write-Host "Restart Claude Code or /reload to pick up the skills."
