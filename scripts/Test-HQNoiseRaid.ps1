param([switch]$ReuseTestMission,[ValidateSet('Ultimate','Plus')][string]$Edition='Ultimate',[string]$CompanionModPath='')
$ErrorActionPreference='Stop'
if(Get-CimInstance Win32_Process -Filter "Name='arma3server_x64.exe'" | Where-Object {$_.CommandLine -match '(?:^|\s)-port=24346(?:\s|$)'}){throw 'An Arma server already uses test port 24346. Stop the owned test before reusing its fixture.'}
$root=Split-Path $PSScriptRoot -Parent
$game='A:\SteamLibrary\steamapps\common\Arma 3'
$workshop='A:\SteamLibrary\steamapps\workshop\content\107410'
$antistasiId=if($Edition -eq 'Ultimate'){'3020755032'}else{'2912941775'}
$profile=(Join-Path $root 'logs\hq-noise-raid') + '-' + $Edition.ToLowerInvariant()
$destination=Join-Path $game 'MPMissions\dsds_raid.VR'
if(Test-Path -LiteralPath $destination){
    if(!$ReuseTestMission -or !(Select-String -LiteralPath (Join-Path $destination 'mission.sqm') -Pattern 'DSDS Noise Raid Validation' -Quiet)){throw 'Raid test mission exists; stop its server before reusing the owned fixture.'}
    Get-ChildItem -LiteralPath (Join-Path $root 'tests\support_services\dsds_raid.VR') -File | ForEach-Object {Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $destination $_.Name) -Force}
}else{Copy-Item -LiteralPath (Join-Path $root 'tests\support_services\dsds_raid.VR') -Destination $destination -Recurse}
New-Item -ItemType Directory -Path $profile -Force | Out-Null
$config=Join-Path $profile 'server.cfg'
@'
hostname="DSDS HQ noise raid validation";
password="local-test-only";
maxPlayers=1;
verifySignatures=0;
persistent=1;
BattlEye=0;
class Missions {class DSDSValidation {template="dsds_raid.VR";difficulty="Regular";};};
'@ | Set-Content -LiteralPath $config -Encoding ascii
$ids=@('619834340','3641926249','2434257231','1665585720','450814997','1779063631','843425103','843577117','843593391','843632231','1673456286',$antistasiId)
$mods=(@($ids | ForEach-Object {Join-Path $workshop $_})+@((Join-Path $root 'build\@DynamicSupplyDrops'),$(if($CompanionModPath){$CompanionModPath}else{Join-Path $root 'build\@AntistasiSupportServices'}))) -join ';'
$arguments=@('-autoInit','-noSound','-ip=127.0.0.1','-port=24346','-name=DSDSRaid',('"-config='+$config+'"'),('"-profiles='+$profile+'"'),('"-mod='+$mods+'"'))
$process=Start-Process -FilePath "$game\arma3server_x64.exe" -WorkingDirectory $game -ArgumentList $arguments -WindowStyle Hidden -PassThru
$process.Id | Set-Content (Join-Path $profile 'server.pid')
Write-Host "HQ raid validation PID $($process.Id). RPT: $profile"
