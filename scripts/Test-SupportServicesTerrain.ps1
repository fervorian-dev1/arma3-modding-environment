param([ValidateSet('Ultimate','Plus')][string]$Edition='Ultimate')
$ErrorActionPreference='Stop'
if(Get-CimInstance Win32_Process -Filter "Name='arma3server_x64.exe'" | Where-Object {$_.CommandLine -match '(?:^|\s)-port=24336(?:\s|$)'}){throw 'An Arma server already uses test port 24336. Stop the owned test before reusing its fixture.'}
$root=Split-Path $PSScriptRoot -Parent
$game='A:\SteamLibrary\steamapps\common\Arma 3'
$workshop='A:\SteamLibrary\steamapps\workshop\content\107410'
$antistasiId=if($Edition -eq 'Ultimate'){'3020755032'}else{'2912941775'}
$profile=(Join-Path $root 'logs\support-services-terrain') + '-' + $Edition.ToLowerInvariant()
$destination=Join-Path $game 'MPMissions\dsds_terrain.Altis'
if(Test-Path -LiteralPath $destination){throw 'Terrain test mission already exists; stop its server and remove the owned fixture before repeating.'}
Copy-Item -LiteralPath (Join-Path $root 'tests\support_services\dsds_terrain.Altis') -Destination $destination -Recurse
New-Item -ItemType Directory -Path $profile -Force | Out-Null
$config=Join-Path $profile 'server.cfg'
@'
hostname="DSDS terrain validation";
password="local-test-only";
maxPlayers=1;
verifySignatures=0;
persistent=1;
BattlEye=0;
class Missions {class DSDSValidation {template="dsds_terrain.Altis";difficulty="Regular";};};
'@ | Set-Content -LiteralPath $config -Encoding ascii
$mods=@("$workshop\450814997","$workshop\1779063631","$workshop\843425103","$workshop\843577117","$workshop\$antistasiId",(Join-Path $root 'build\@DynamicSupplyDrops'),(Join-Path $root 'build\@AntistasiSupportServices')) -join ';'
$arguments=@('-autoInit','-noSound','-ip=127.0.0.1','-port=24336','-name=DSDSTerrain',('"-config='+$config+'"'),('"-profiles='+$profile+'"'),('"-mod='+$mods+'"'))
$process=Start-Process -FilePath "$game\arma3server_x64.exe" -WorkingDirectory $game -ArgumentList $arguments -WindowStyle Hidden -PassThru
$process.Id | Set-Content (Join-Path $profile 'server.pid')
Write-Host "Terrain validation PID $($process.Id). RPT: $profile"
