param([string]$CompanionModPath='')
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$game='A:\SteamLibrary\steamapps\common\Arma 3'
$workshop='A:\SteamLibrary\steamapps\workshop\content\107410'
$antistasiId='3020755032'
if(Get-CimInstance Win32_Process -Filter "Name='arma3_x64.exe' OR Name='arma3.exe'"){throw 'Close the normal game before starting the isolated player validation.'}
$profile=Join-Path $root 'logs\travel-mp-client-validation'
New-Item -ItemType Directory -Path $profile -Force | Out-Null
$mods=@("$workshop\619834340","$workshop\3641926249","$workshop\2434257231","$workshop\450814997","$workshop\3295358796","$workshop\1665585720","$workshop\1779063631","$workshop\843425103","$workshop\843577117","$workshop\$antistasiId","$workshop\402601958","$workshop\3045129955","$workshop\2333743487","$workshop\3612124287","$workshop\1242693518",(Join-Path $root 'build\@DynamicSupplyDrops'),$(if($CompanionModPath){$CompanionModPath}else{Join-Path $root 'build\@AntistasiSupportServices'})) -join ';'
$arguments=@('-filePatching','-noSplash','-skipIntro','-noSound','-noPause','-window','-x=960','-y=540','-world=empty','-name=DSDSTravelMPClient',('"-profiles='+$profile+'"'),('"-mod='+$mods+'"'),'-connect=127.0.0.1','-port=24506','-password=local-test-only')
$process=Start-Process -FilePath "$game\arma3_x64.exe" -WorkingDirectory $game -ArgumentList $arguments -WindowStyle Hidden -PassThru
$process.Id | Set-Content -LiteralPath (Join-Path $profile 'client.pid')
Write-Host "Owned travel-garage client PID $($process.Id), separate profile $profile"


