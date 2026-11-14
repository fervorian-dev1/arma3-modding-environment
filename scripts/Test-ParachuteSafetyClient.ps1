param([string]$CompanionModPath='')
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$game='A:\SteamLibrary\steamapps\common\Arma 3'
$workshop='A:\SteamLibrary\steamapps\workshop\content\107410'
$antistasiId='3020755032'
if(Get-CimInstance Win32_Process -Filter "Name='arma3_x64.exe' OR Name='arma3.exe'"){throw 'Close the normal game before starting the isolated player validation.'}
$profile=Join-Path $root 'logs\parachute49-client-validation'
New-Item -ItemType Directory -Path $profile -Force | Out-Null
$destination=Join-Path $game 'Missions\dsds_parachute49.Altis'
if(Test-Path -LiteralPath $destination){
 if(!(Select-String -LiteralPath (Join-Path $destination 'mission.sqm') -SimpleMatch 'DSDS Parachute Safety Validation' -Quiet)){throw 'Unowned travel-garage fixture'}
 Get-ChildItem -LiteralPath (Join-Path $root 'tests\support_services\dsds_parachute49.Altis') -File | ForEach-Object {Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $destination $_.Name) -Force}
}else{Copy-Item -LiteralPath (Join-Path $root 'tests\support_services\dsds_parachute49.Altis') -Destination $destination -Recurse}
$missionStage=Join-Path $root 'temp\travel-garage-mission-stage'
New-Item -ItemType Directory -Path $missionStage -Force | Out-Null
& 'A:\SteamLibrary\steamapps\common\Arma 3 Tools\FileBank\FileBank.exe' -dst $missionStage (Join-Path $root 'tests\support_services\dsds_parachute49.Altis')
if($LASTEXITCODE -ne 0){throw 'TravelGarage mission packing failed'}
Copy-Item -LiteralPath (Join-Path $missionStage 'dsds_parachute49.Altis.pbo') -Destination (Join-Path $game 'Missions\dsds_parachute49.Altis.pbo') -Force
$mods=@("$workshop\619834340","$workshop\3641926249","$workshop\2434257231","$workshop\450814997","$workshop\3295358796","$workshop\1665585720","$workshop\1779063631","$workshop\843425103","$workshop\843577117","$workshop\$antistasiId","$workshop\402601958","$workshop\3045129955","$workshop\2333743487","$workshop\3612124287","$workshop\1242693518",(Join-Path $root 'build\@DynamicSupplyDrops'),$(if($CompanionModPath){$CompanionModPath}else{Join-Path $root 'build\@AntistasiSupportServices'})) -join ';'
$autotest=Join-Path $profile 'autotest.cfg'
$testMission=Join-Path $game 'Missions\dsds_parachute49.Altis'
('class TestMissions {class TravelGarage {campaign="";mission="'+$testMission+'";};};') | Set-Content -LiteralPath $autotest -Encoding ascii
$gameTestCfg=Join-Path $game 'dsds_parachute49_autotest.cfg'
if((Test-Path -LiteralPath $gameTestCfg) -and !(Select-String -LiteralPath $gameTestCfg -SimpleMatch 'dsds_parachute49.Altis' -Quiet)){throw 'Unowned autotest config at destination'}
Copy-Item -LiteralPath $autotest -Destination $gameTestCfg -Force
$arguments=@('-filePatching','-noSplash','-skipIntro','-noSound','-noPause','-window','-x=960','-y=540','-world=empty','-name=DSDSParachute49',('"-profiles='+$profile+'"'),('"-mod='+$mods+'"'),'-autotest=dsds_parachute49_autotest.cfg')
$process=Start-Process -FilePath "$game\arma3_x64.exe" -WorkingDirectory $game -ArgumentList $arguments -WindowStyle Hidden -PassThru
$process.Id | Set-Content -LiteralPath (Join-Path $profile 'client.pid')
Write-Host "Owned travel-garage client PID $($process.Id), separate profile $profile"

