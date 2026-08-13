#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

Write-Host "==> init submodules"
git submodule update --init --recursive
if ($LASTEXITCODE -ne 0) { throw "git submodule update failed" }

$Modules = @(
    @{ Path = "MCDevTool";    Upstream = "https://github.com/GitHub-Zero123/MCDevTool.git" },
    @{ Path = "mcdev-tools";  Upstream = "https://github.com/Dofes/mcdev-tools.git" }
)

foreach ($mod in $Modules) {
    $dir = Join-Path $Root $mod.Path
    if (-not (Test-Path (Join-Path $dir ".git"))) {
        throw "submodule not initialized: $($mod.Path)"
    }

    Write-Host "==> $($mod.Path): checkout main"
    git -C $dir checkout main
    if ($LASTEXITCODE -ne 0) { throw "checkout main failed in $($mod.Path)" }

    $remotes = git -C $dir remote
    if ($remotes -notcontains "upstream") {
        Write-Host "==> $($mod.Path): add upstream $($mod.Upstream)"
        git -C $dir remote add upstream $mod.Upstream
        if ($LASTEXITCODE -ne 0) { throw "add upstream failed in $($mod.Path)" }
    } else {
        Write-Host "==> $($mod.Path): upstream already exists"
    }

    git -C $dir remote -v
}

Write-Host "setup done."
