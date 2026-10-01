<#
.SYNOPSIS
  Runs one faegentic-x subtask on the opposite model family through its headless CLI.

.EXAMPLE
  pwsh -NoProfile -File cross.ps1 -To gpt -Role write -Brief .faegentic/door/01-core/brief.md -Dir .
#>
param(
    [Parameter(Mandatory)][ValidateSet('gpt', 'claude')][string]$To,
    [Parameter(Mandatory)][ValidateSet('write', 'fix', 'review')][string]$Role,
    [Parameter(Mandatory)][string]$Brief,
    [string]$Dir = '.',
    [string]$Effort = 'max',
    [string]$Model
)

$ErrorActionPreference = 'Stop'

$skillDir = Split-Path -Parent $PSScriptRoot
$briefPath = (Resolve-Path $Brief).Path
$workDir = (Resolve-Path $Dir).Path
$outDir = Split-Path -Parent $briefPath

if (-not $Model) {
    $Model = if ($To -eq 'gpt') { 'gpt-6.1-sol' } else { 'claude-opus-5-5' }
}

# Next free run number for this role: write-1.md, write-2.md, ...
$n = 1
while (Test-Path (Join-Path $outDir "$Role-$n.md")) { $n++ }
$resultFile = Join-Path $outDir "$Role-$n.md"
$logFile = Join-Path $outDir "$Role-$n.log"

$preambleName = if ($Role -eq 'review') { 'reviewer-preamble.md' } else { 'writer-preamble.md' }
$preamble = Get-Content -Raw (Join-Path $skillDir "references/$preambleName")
$prompt = $preamble + "`n`n---`n`n" + (Get-Content -Raw $briefPath)

$started = Get-Date
"[$started] to=$To role=$Role model=$Model effort=$Effort dir=$workDir" | Set-Content $logFile

if ($To -eq 'gpt') {
    $sandbox = if ($Role -eq 'review') { 'read-only' } else { 'workspace-write' }
    $prompt | & codex exec `
        -m $Model `
        -c "model_reasoning_effort=`"$Effort`"" `
        -s $sandbox `
        -C $workDir `
        -o $resultFile `
        - *>> $logFile
}
else {
    # Claude effort levels stop at max; map Codex-only levels down.
    $claudeEffort = if ($Effort -in 'low', 'medium', 'high', 'xhigh', 'max') { $Effort } else { 'max' }
    $tools = if ($Role -eq 'review') {
        'Read', 'Glob', 'Grep', 'Bash(git diff:*)', 'Bash(git status:*)', 'Bash(git log:*)', 'Bash(git show:*)'
    }
    else {
        'Read', 'Edit', 'Write', 'Glob', 'Grep', 'Bash(git diff:*)', 'Bash(git status:*)', 'Bash(git log:*)'
    }
    Push-Location $workDir
    try {
        $prompt | & claude -p `
            --model $Model `
            --effort $claudeEffort `
            --permission-mode dontAsk `
            --allowedTools @tools `
            --output-format text `
            2>> $logFile | Set-Content $resultFile
    }
    finally { Pop-Location }
}

$code = $LASTEXITCODE
$elapsed = [int]((Get-Date) - $started).TotalSeconds
"[$(Get-Date)] exit=$code elapsed=${elapsed}s" | Add-Content $logFile

if ($code -ne 0 -or -not (Test-Path $resultFile) -or (Get-Item $resultFile).Length -eq 0) {
    Write-Error "cross.ps1: $To $Role failed (exit $code). See $logFile"
    exit 1
}

Write-Output "OK $To $Role -> $resultFile (${elapsed}s)"
