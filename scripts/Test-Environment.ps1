param([switch]$Launch)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$tools = 'A:\SteamLibrary\steamapps\common\Arma 3 Tools'
$source = Join-Path $root 'projects\environment_smoke\addons\env_smoke'
$output = Join-Path $root 'build\@environment_smoke\addons'
New-Item -ItemType Directory -Path $output -Force | Out-Null
& "$tools\CfgConvert\CfgConvert.exe" -test "$source\config.cpp"
if ($LASTEXITCODE -ne 0) { throw 'Config validation failed' }
& "$tools\FileBank\FileBank.exe" -property 'prefix=env_smoke' -dst $output $source
if ($LASTEXITCODE -ne 0) { throw 'PBO build failed' }
$pbo = Join-Path $output 'env_smoke.pbo'
if (!(Test-Path $pbo)) { throw 'PBO output missing' }
$listing = & "$tools\BankRev\BankRev.exe" -l $pbo
if ($LASTEXITCODE -ne 0 -or $listing -notmatch 'config.cpp') { throw 'PBO inspection failed' }
Write-Host "Build verified: $pbo"
if ($Launch) {
    $profile = Join-Path $root 'logs\smoke-profile'
    New-Item -ItemType Directory -Path $profile -Force | Out-Null
    $mod = Join-Path $root 'build\@environment_smoke'
    Start-Process -FilePath 'A:\SteamLibrary\steamapps\common\Arma 3\arma3_x64.exe' -ArgumentList @('-noSplash', '-showScriptErrors', ('"-mod=' + $mod + '"'), ('"-profiles=' + $profile + '"')) -WorkingDirectory 'A:\SteamLibrary\steamapps\common\Arma 3'
}
