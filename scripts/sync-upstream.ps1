#Requires -Version 5.1
param(
    [ValidateSet("all", "MCDevTool", "mcdev-tools")]
    [string]$Target = "all"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot

$Modules = @{
    "MCDevTool"   = @{ Path = "MCDevTool";   Upstream = "https://github.com/GitHub-Zero123/MCDevTool.git" }
    "mcdev-tools" = @{ Path = "mcdev-tools"; Upstream = "https://github.com/Dofes/mcdev-tools.git" }
}

$names = if ($Target -eq "all") { @("MCDevTool", "mcdev-tools") } else { @($Target) }

foreach ($name in $names) {
    $mod = $Modules[$name]
    $dir = Join-Path $Root $mod.Path
    if (-not (Test-Path (Join-Path $dir ".git"))) {
        throw "submodule not initialized: $name. Run .\scripts\setup.ps1 first."
    }

    Write-Host "==> $name: check working tree"
    $status = git -C $dir status --porcelain
    if ($status) {
        Write-Host "skip $name: working tree is dirty"
        Write-Host $status
        continue
    }

    $remotes = git -C $dir remote
    if ($remotes -notcontains "upstream") {
        git -C $dir remote add upstream $mod.Upstream
        if ($LASTEXITCODE -ne 0) { throw "add upstream failed in $name" }
    }

    Write-Host "==> $name: fetch upstream"
    git -C $dir fetch upstream
    if ($LASTEXITCODE -ne 0) { throw "fetch upstream failed in $name" }

    Write-Host "==> $name: checkout main"
    git -C $dir checkout main
    if ($LASTEXITCODE -ne 0) { throw "checkout main failed in $name" }

    Write-Host "==> $name: rebase onto upstream/main"
    git -C $dir rebase upstream/main
    if ($LASTEXITCODE -ne 0) {
        Write-Host "rebase conflict in $name. Resolve it, then: git -C $name rebase --continue"
        throw "rebase failed in $name"
    }

    Write-Host "==> $name: push origin main"
    git -C $dir push origin main
    if ($LASTEXITCODE -ne 0) { throw "push origin failed in $name" }
}

Write-Host "sync-upstream done. If submodule pointers moved, commit them in the umbrella repo:"
Write-Host "  git add MCDevTool mcdev-tools"
Write-Host "  git commit -m `"chore: bump submodules`""
