param()
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$tools = 'A:\SteamLibrary\steamapps\common\Arma 3 Tools'
$source = Join-Path $root 'projects\dynamic_supply_drops\addons\dsd_supplydrops'
$mod = Join-Path $root 'build\@DynamicSupplyDrops'
New-Item -ItemType Directory -Path "$mod\addons" -Force | Out-Null
& "$tools\CfgConvert\CfgConvert.exe" -test "$source\config.cpp"
if ($LASTEXITCODE -ne 0) { throw 'Config validation failed' }
& "$tools\FileBank\FileBank.exe" -property 'prefix=dsd_supplydrops' -dst "$mod\addons" $source
if ($LASTEXITCODE -ne 0) { throw 'PBO build failed' }
$listing = & "$tools\BankRev\BankRev.exe" -l "$mod\addons\dsd_supplydrops.pbo"
if ($LASTEXITCODE -ne 0) { throw 'PBO inspection failed' }
$functions = Get-ChildItem "$source\functions\SupplyDrops" -Filter 'fn_*.sqf' | Sort-Object Name
foreach ($function in $functions) {
    if (!($listing -match [regex]::Escape($function.Name))) { throw "Missing packaged function: $($function.Name)" }
}
Copy-Item (Join-Path $root 'projects\dynamic_supply_drops\mod.cpp') "$mod\mod.cpp" -Force
# Self-contained SQF for ZEN Execute Code / Global in an already running mission.
$bundle = @('// Dynamic Supply Drops v1.1.0 live bootstrap. Execute GLOBAL AND JIP in ZEN Execute Code.', '// Keep the resulting ZEN module for late joiners; initialization is idempotent.')
foreach ($function in $functions) {
    $name = $function.BaseName.Substring(3)
    $body = Get-Content -LiteralPath $function.FullName -Raw
    $bundle += "DSD_fnc_$name = {`n$body`n};"
}
$bundle += '[] call DSD_fnc_initSupplyDrops;'
$bundlePath = Join-Path $root 'projects\dynamic_supply_drops\LIVE_BOOTSTRAP.sqf'
[IO.File]::WriteAllText($bundlePath, ($bundle -join "`n"), [Text.Encoding]::UTF8)
Write-Host "Built $mod"
Write-Host "Packaged $($functions.Count) functions; generated $bundlePath"
