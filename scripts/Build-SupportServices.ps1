param([string]$OutputModPath='')
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$tools = 'A:\SteamLibrary\steamapps\common\Arma 3 Tools'
$project = Join-Path $root 'projects\antistasi_support_services'
$source = Join-Path $project 'addons\dsds_support'
$mod = if ($OutputModPath) {[IO.Path]::GetFullPath($OutputModPath)} else {Join-Path $root 'build\@AntistasiSupportServices'}
New-Item -ItemType Directory -Path "$mod\addons" -Force | Out-Null
& "$tools\CfgConvert\CfgConvert.exe" -test "$source\config.cpp"
if ($LASTEXITCODE -ne 0) {throw 'Support Services configuration validation failed'}
# FileBank can return success without replacing a PBO held open by Arma.
# Always pack a fresh candidate, verify every source file, then publish via Copy-Item.
$stage = Join-Path $root ('temp\support-build-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $stage -Force | Out-Null
$candidate = Join-Path $stage 'dsds_support.pbo'
& "$tools\FileBank\FileBank.exe" -property 'prefix=dsds_support' -dst $stage $source
if ($LASTEXITCODE -ne 0) {throw 'Support Services packaging failed'}
$listing = & "$tools\BankRev\BankRev.exe" -l $candidate
if ($LASTEXITCODE -ne 0) {throw 'Support Services package inspection failed'}
$functions = Get-ChildItem "$source\functions" -Filter 'fn_*.sqf' -Recurse
foreach ($function in $functions) {
    if (!($listing -match [regex]::Escape($function.Name))) {throw "Missing function $($function.Name)"}
}
$verify = Join-Path $stage 'verify'
& "$tools\BankRev\BankRev.exe" -f $verify $candidate | Out-Null
if ($LASTEXITCODE -ne 0) {throw 'Candidate extraction failed'}
foreach ($file in (Get-ChildItem -LiteralPath $source -File -Recurse)) {
    $relative = $file.FullName.Substring($source.Length + 1)
    $packed = Join-Path (Join-Path $verify 'dsds_support') $relative
    if (!(Test-Path -LiteralPath $packed) -or (Get-FileHash -LiteralPath $packed).Hash -ne (Get-FileHash -LiteralPath $file.FullName).Hash) {
        throw "Packed file differs from source: $relative"
    }
}
Copy-Item -LiteralPath $candidate -Destination "$mod\addons\dsds_support.pbo" -Force
if ((Get-FileHash -LiteralPath $candidate).Hash -ne (Get-FileHash -LiteralPath "$mod\addons\dsds_support.pbo").Hash) {throw 'Published PBO does not match verified candidate'}
Copy-Item "$project\mod.cpp" "$mod\mod.cpp" -Force
Copy-Item "$project\README.md" "$mod\README.md" -Force
Write-Host "Built $mod with $($functions.Count) functions. Requires game/server restart and the original Dynamic Supply Drops addon."
