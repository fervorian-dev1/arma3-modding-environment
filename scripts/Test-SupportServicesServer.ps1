param([switch]$ReuseTestMission,[ValidateSet('Full','RestoreAlive','RestoreDead','Regression')][string]$Phase='Full',[ValidateSet('Ultimate','Plus')][string]$Edition='Ultimate')
$ErrorActionPreference = 'Stop'
if(Get-CimInstance Win32_Process -Filter "Name='arma3server_x64.exe'" | Where-Object {$_.CommandLine -match '(?:^|\s)-port=24326(?:\s|$)'}){throw 'An Arma server already uses test port 24326. Stop the owned test before reusing its fixture.'}
$root = Split-Path $PSScriptRoot -Parent
$game = 'A:\SteamLibrary\steamapps\common\Arma 3'
$workshop = 'A:\SteamLibrary\steamapps\workshop\content\107410'
$antistasiId=if($Edition -eq 'Ultimate'){'3020755032'}else{'2912941775'}
$profile =(Join-Path $root 'logs\support-services-validation') + '-' + $Edition.ToLowerInvariant()
New-Item -ItemType Directory -Path $profile -Force | Out-Null
$source = Join-Path $root 'tests\support_services\dsds_validation.VR'
$destination = Join-Path $game 'MPMissions\dsds_validation.VR'
if (Test-Path $destination) {
    if (!$ReuseTestMission -or !(Select-String -LiteralPath "$destination\mission.sqm" -Pattern 'DSDS Support Services Validation' -Quiet)) {throw 'Test destination exists; stop its server before reusing it.'}
    foreach ($alias in @('initPlayerLocal.sqf','initPlayerServer.sqf','phase.sqf')) {
        $aliasPath=Join-Path $destination $alias
        if(Test-Path -LiteralPath $aliasPath){Remove-Item -LiteralPath $aliasPath}
    }
    Get-ChildItem -LiteralPath $source -File | ForEach-Object {Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $destination $_.Name) -Force}
} else {Copy-Item -LiteralPath $source -Destination $destination -Recurse}
if ($Phase -in @('RestoreAlive','RestoreDead')) {
    Copy-Item -LiteralPath (Join-Path $source 'initServerRestore.sqf') -Destination (Join-Path $destination 'initServer.sqf') -Force
    ('DSDS_expectAlive = ' + $(if($Phase -eq 'RestoreAlive'){'true'}else{'false'}) + ';') | Set-Content (Join-Path $destination 'phase.sqf') -Encoding ascii
}
if ($Phase -eq 'Regression') {
    Copy-Item -LiteralPath (Join-Path $source 'initServerRegression.sqf') -Destination (Join-Path $destination 'initServer.sqf') -Force
    Copy-Item -LiteralPath (Join-Path $source 'initPlayerLocalUI.sqf') -Destination (Join-Path $destination 'initPlayerLocal.sqf') -Force
    Copy-Item -LiteralPath (Join-Path $source 'initPlayerServerUI.sqf') -Destination (Join-Path $destination 'initPlayerServer.sqf') -Force
}
$config = Join-Path $profile 'server.cfg'
@'
hostname="DSDS local validation";
password="local-test-only";
maxPlayers=1;
verifySignatures=0;
persistent=1;
BattlEye=0;
class Missions {class DSDSValidation {template="dsds_validation.VR";difficulty="Regular";};};
'@ | Set-Content -LiteralPath $config -Encoding ascii
$mods = @("$workshop\450814997","$workshop\1779063631","$workshop\843425103","$workshop\843577117","$workshop\$antistasiId",(Join-Path $root 'build\@DynamicSupplyDrops'),(Join-Path $root 'build\@AntistasiSupportServices')) -join ';'
$arguments = @('-autoInit','-noSound','-ip=127.0.0.1','-port=24326','-name=DSDSValidation',('"-config='+$config+'"'),('"-profiles='+$profile+'"'),('"-mod='+$mods+'"'))
$process=Start-Process -FilePath "$game\arma3server_x64.exe" -WorkingDirectory $game -ArgumentList $arguments -WindowStyle Hidden -PassThru
$process.Id | Set-Content (Join-Path $profile 'server.pid')
Write-Host "Support Services validation PID $($process.Id). RPT: $profile"
