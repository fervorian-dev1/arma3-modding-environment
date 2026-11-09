param([switch]$ReuseTestMission, [switch]$LiveBootstrap, [switch]$Antistasi,[ValidateSet('Ultimate','Plus')][string]$Edition='Ultimate')
$ErrorActionPreference = 'Stop'
$testPort = if ($LiveBootstrap) {24324} else {24322}
if(Get-CimInstance Win32_Process -Filter "Name='arma3server_x64.exe'" | Where-Object {$_.CommandLine -match ('(?:^|\s)-port='+$testPort+'(?:\s|$)')}){throw 'An Arma server already uses this test port. Stop the owned test before reusing its fixture.'}
$root = Split-Path $PSScriptRoot -Parent
$game = 'A:\SteamLibrary\steamapps\common\Arma 3'
$workshop = 'A:\SteamLibrary\steamapps\workshop\content\107410'
$antistasiId=if($Edition -eq 'Ultimate'){'3020755032'}else{'2912941775'}
$profile =(Join-Path $root $(if ($LiveBootstrap) {'logs\supply-live-validation'} else {'logs\supply-validation'})) + '-' + $Edition.ToLowerInvariant()
New-Item -ItemType Directory -Path $profile -Force | Out-Null
$missionName = if ($LiveBootstrap) {'dsd_live_validation.VR'} else {'dsd_validation.VR'}
$mission = Join-Path $game "MPMissions\$missionName"
if (Test-Path $mission) {
    if (!$ReuseTestMission -or !(Select-String -LiteralPath "$mission\mission.sqm" -Pattern 'DSD Automated Validation' -Quiet)) {
        throw "Test mission destination already exists: $mission. Use -ReuseTestMission only for the previous test copy after its server is stopped."
    }
    foreach ($file in @('mission.sqm','description.ext','initServer.sqf','testAntistasi.sqf')) {
        Copy-Item (Join-Path $root "tests\supply_drops\dsd_validation.VR\$file") (Join-Path $mission $file) -Force
    }
} else {
    Copy-Item (Join-Path $root 'tests\supply_drops\dsd_validation.VR') $mission -Recurse
}
if ($LiveBootstrap) {
    Copy-Item (Join-Path $root 'projects\dynamic_supply_drops\LIVE_BOOTSTRAP.sqf') (Join-Path $mission 'LIVE_BOOTSTRAP.sqf') -Force
}
$config = Join-Path $profile 'server.cfg'
@'
hostname = "DSD local validation";
password = "local-test-only";
maxPlayers = 1;
verifySignatures = 0;
persistent = 1;
BattlEye = 0;
allowedFilePatching = 0;
class Missions {
    class DSDValidation { template = "dsd_validation.VR"; difficulty = "Regular"; };
};
'@ | ForEach-Object {$_ -replace 'dsd_validation.VR', $missionName} | Set-Content $config -Encoding ascii
$modList = @("$workshop\450814997", "$workshop\1779063631", "$workshop\843425103", "$workshop\843577117")
if ($Antistasi) {$modList += "$workshop\$antistasiId"}
if (!$LiveBootstrap) {$modList += (Join-Path $root 'build\@DynamicSupplyDrops')}
$mods = $modList -join ';'
$port = if ($LiveBootstrap) {24324} else {24322}
$argsList = @('-autoInit', '-noSound', '-ip=127.0.0.1', "-port=$port", ('"-config=' + $config + '"'), ('"-profiles=' + $profile + '"'), ('"-mod=' + $mods + '"'))
$process = Start-Process -FilePath "$game\arma3server_x64.exe" -WorkingDirectory $game -ArgumentList $argsList -WindowStyle Hidden -PassThru
$process.Id | Set-Content (Join-Path $profile 'server.pid')
Write-Host "Local validation server PID $($process.Id); logs: $profile"
Write-Host "Temporary test mission installed at $mission"
