param([switch]$ReuseTestMission,[ValidateSet('Ultimate','Plus')][string]$Edition='Ultimate')
$ErrorActionPreference='Stop'
if(Get-CimInstance Win32_Process -Filter "Name='arma3server_x64.exe'" | Where-Object {$_.CommandLine -match '(?:^|\s)-port=24406(?:\s|$)'}){throw 'An Arma server already uses test port 24406. Stop the owned test before reusing its fixture.'}
$root=Split-Path $PSScriptRoot -Parent
$game='A:\SteamLibrary\steamapps\common\Arma 3'
$workshop='A:\SteamLibrary\steamapps\workshop\content\107410'
$antistasiId=if($Edition -eq 'Ultimate'){'3020755032'}else{'2912941775'}
$testProfileDirectory=(Join-Path $root 'logs\logistics-validation') + '-' + $Edition.ToLowerInvariant()
$destination=Join-Path $game 'MPMissions\dsds_logistics.Altis'
if(Test-Path -LiteralPath $destination){
    if(!$ReuseTestMission -or !(Select-String -LiteralPath (Join-Path $destination 'mission.sqm') -Pattern 'DSDS Logistics Validation' -Quiet)){throw 'Logistics test destination exists and is not approved for fixture reuse.'}
    if(Get-CimInstance Win32_Process -Filter "Name='arma3server_x64.exe'" | Where-Object {$_.CommandLine -like '*-port=24406*'}){throw 'Owned Logistics server is still running.'}
    Get-ChildItem -LiteralPath (Join-Path $root 'tests\support_services\dsds_logistics.Altis') -File | ForEach-Object {Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $destination $_.Name) -Force}
}else{
Copy-Item -LiteralPath (Join-Path $root 'tests\support_services\dsds_logistics.Altis') -Destination $destination -Recurse
}
New-Item -ItemType Directory -Path $testProfileDirectory -Force | Out-Null
$config=Join-Path $testProfileDirectory 'server.cfg'
@'
hostname="DSDS Logistics validation";
password="local-test-only";
maxPlayers=1;
verifySignatures=0;
persistent=1;
BattlEye=0;
class Missions {class DSDSValidation {template="dsds_logistics.Altis";difficulty="Regular";};};
'@ | Set-Content -LiteralPath $config -Encoding ascii
$mods=@("$workshop\619834340","$workshop\3641926249","$workshop\2434257231","$workshop\450814997","$workshop\3295358796","$workshop\1779063631","$workshop\843425103","$workshop\843577117","$workshop\843593391","$workshop\843632231","$workshop\1673456286","$workshop\$antistasiId","$workshop\402601958","$workshop\3045129955","$workshop\2333743487","$workshop\3612124287","$workshop\1242693518",(Join-Path $root 'build\@DynamicSupplyDrops'),(Join-Path $root 'temp\@LogisticsCandidate')) -join ';'
$arguments=@('-autoInit','-noSound','-ip=127.0.0.1','-port=24406','-name=DSDSLogistics',('"-config='+$config+'"'),('"-profiles='+$testProfileDirectory+'"'),('"-mod='+$mods+'"'))
$process=Start-Process -FilePath "$game\arma3server_x64.exe" -WorkingDirectory $game -ArgumentList $arguments -WindowStyle Hidden -PassThru
$process.Id | Set-Content (Join-Path $testProfileDirectory 'server.pid')
Write-Host "Logistics validation PID $($process.Id). RPT: $testProfileDirectory"



