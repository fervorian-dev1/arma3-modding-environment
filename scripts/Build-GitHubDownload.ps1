param([string]$Version='3.6')
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
if($Version -notmatch '^\d+\.\d+(\.\d+)?$'){throw 'Use a numeric release version.'}
$stage=Join-Path $root ('temp\github-download-'+$Version)
$output=Join-Path $root 'build\releases'
New-Item -ItemType Directory -Path $stage,$output -Force | Out-Null
$mods=@('@DynamicSupplyDrops','@AntistasiSupportServices')
$hashes=@()
foreach($name in $mods){
    $source=Join-Path (Join-Path $root 'build') $name
    if(!(Test-Path -LiteralPath (Join-Path $source 'addons'))){throw "Build $name before packaging."}
    $destination=Join-Path $stage $name
    New-Item -ItemType Directory -Path (Join-Path $destination 'addons') -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $source 'mod.cpp') -Destination (Join-Path $destination 'mod.cpp') -Force
    $pbos=@(Get-ChildItem -LiteralPath (Join-Path $source 'addons') -Filter '*.pbo' -File)
    if($pbos.Count -ne 1){throw "Expected one custom addon in $name."}
    foreach($pbo in $pbos){
        $packed=Join-Path (Join-Path $destination 'addons') $pbo.Name
        Copy-Item -LiteralPath $pbo.FullName -Destination $packed -Force
        $hash=(Get-FileHash -LiteralPath $packed -Algorithm SHA256).Hash
        if($hash -ne (Get-FileHash -LiteralPath $pbo.FullName -Algorithm SHA256).Hash){throw 'Download copy differs from current build.'}
        $hashes+=($hash+'  '+$name+'/addons/'+$pbo.Name)
    }
    "See ../INSTALL.txt for installation. Source and development notes are in the GitHub repository." | Set-Content -LiteralPath (Join-Path $destination 'README.txt') -Encoding utf8
}
@"
ARMA 3 CUSTOM MODS - SUPPORT SERVICES v$Version

1. Extract this whole ZIP somewhere permanent on your computer.
2. In Arma 3 Launcher: Mods > Local mod. Select @DynamicSupplyDrops.
3. Repeat for @AntistasiSupportServices. Select the FOLDERS, not the PBO files.
4. Enable both, plus the same Steam Workshop mods used by your host.
5. Restart Arma before joining. Host/server and all friends need this same version.

Core dependencies: CBA_A3, Zeus Enhanced and Antistasi Ultimate.
The host's other Workshop content mods are required for the same vehicles/equipment.
Chemical Warfare PLUS is needed for isotope contamination features.
This ZIP contains our custom mods only; it does not contain Arma or Workshop mods.

Updating: replace your previous copies of these two folders and restart Arma.
Enable only one copy of each. No campaign reset is required.
Addons are unsigned; a signature-enforcing server needs appropriate accepted signing.

The GitHub source-code ZIP is for development. This release ZIP is ready to play.
SHA256SUMS.txt records the packaged PBO hashes.
"@ | Set-Content -LiteralPath (Join-Path $stage 'INSTALL.txt') -Encoding utf8
$hashes | Set-Content -LiteralPath (Join-Path $stage 'SHA256SUMS.txt') -Encoding ascii
$archive=Join-Path $output ('Arma3-Custom-Mods-v'+$Version+'.zip')
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $archive -Force
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip=[IO.Compression.ZipFile]::OpenRead($archive)
try{
    $entries=@($zip.Entries | ForEach-Object {$_.FullName.Replace('\','/')})
    foreach($required in @('INSTALL.txt','SHA256SUMS.txt','@DynamicSupplyDrops/addons/dsd_supplydrops.pbo','@AntistasiSupportServices/addons/dsds_support.pbo')){
        if($required -notin $entries){throw "Release ZIP missing $required"}
    }
}finally{$zip.Dispose()}
Get-Item -LiteralPath $archive | Select-Object FullName,Length
Get-FileHash -LiteralPath $archive -Algorithm SHA256
