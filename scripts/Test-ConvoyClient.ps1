param()
$ErrorActionPreference='Stop'
if(Get-Process arma3_x64 -ErrorAction SilentlyContinue){throw 'A normal game client is running; leave it untouched.'}
$root=Split-Path $PSScriptRoot -Parent
$game='A:\SteamLibrary\steamapps\common\Arma 3'
$workshop='A:\SteamLibrary\steamapps\workshop\content\107410'
$server=Get-CimInstance Win32_Process -Filter "Name='arma3server_x64.exe'" | Where-Object {$_.CommandLine -match '(?:^|\s)-port=24396(?:\s|$)' -and $_.CommandLine -like '*-profiles=A:\arma3 modding enviroment\logs\convoy-defenses-validation-ultimate"*'}
if(!$server){throw 'Start the owned Convoy Defenses validation server first.'}
$testProfileDirectory=Join-Path $root 'logs\convoy-client-validation'
New-Item -ItemType Directory -Path $testProfileDirectory -Force | Out-Null
$graphics=Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Arma 3\Arma3.cfg'
if(Test-Path -LiteralPath $graphics){Copy-Item -LiteralPath $graphics -Destination (Join-Path $testProfileDirectory 'Arma3.cfg') -Force}
$mods=@("$workshop\619834340","$workshop\3641926249","$workshop\2434257231","$workshop\450814997","$workshop\3295358796","$workshop\1779063631","$workshop\843425103","$workshop\843577117","$workshop\3020755032","$workshop\402601958","$workshop\3045129955","$workshop\2333743487","$workshop\3612124287","$workshop\1242693518",(Join-Path $root 'build\@DynamicSupplyDrops'),(Join-Path $root 'build\@AntistasiSupportServices')) -join ';'
$arguments=@('-noSplash','-skipIntro','-world=empty','-noPause','-window','-noSound','-connect=127.0.0.1','-port=24396','-password=local-test-only','-name=DSDSConvoyClient',('"-profiles='+$testProfileDirectory+'"'),('"-mod='+$mods+'"'))
$process=Start-Process -FilePath "$game\arma3_x64.exe" -WorkingDirectory $game -ArgumentList $arguments -WindowStyle Hidden -PassThru
$process.Id | Set-Content -LiteralPath (Join-Path $testProfileDirectory 'client.pid')
Write-Host "Owned loopback CWP client PID $($process.Id). Profile: $testProfileDirectory"
