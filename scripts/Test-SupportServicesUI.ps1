param([switch]$Visible,[ValidateSet('Ultimate','Plus')][string]$Edition='Ultimate')
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
if(Get-Process arma3_x64 -ErrorAction SilentlyContinue){throw 'A game client is already running; leave it untouched and run this isolated test after closing it.'}
& (Join-Path $PSScriptRoot 'Test-SupportServicesServer.ps1') -ReuseTestMission -Phase Regression -Edition $Edition
$game='A:\SteamLibrary\steamapps\common\Arma 3'
$workshop='A:\SteamLibrary\steamapps\workshop\content\107410'
$antistasiId=if($Edition -eq 'Ultimate'){'3020755032'}else{'2912941775'}
$profile=(Join-Path $root 'logs\support-services-ui') + '-' + $Edition.ToLowerInvariant()
New-Item -ItemType Directory -Path $profile -Force | Out-Null
$mods=@("$workshop\450814997","$workshop\1779063631","$workshop\843425103","$workshop\843577117","$workshop\$antistasiId",(Join-Path $root 'build\@DynamicSupplyDrops'),(Join-Path $root 'build\@AntistasiSupportServices')) -join ';'
# Official -connect/-password/-window parameters; isolated profile, no campaign save.
# https://community.bistudio.com/wiki/Arma_3_Startup_Parameters
$arguments=@('-noSplash','-skipIntro','-world=empty','-noPause','-window','-noSound','-connect=127.0.0.1','-port=24326','-password=local-test-only','-name=DSDSUI',('"-profiles='+$profile+'"'),('"-mod='+$mods+'"'))
$windowStyle=if($Visible){'Normal'}else{'Hidden'}
$process=Start-Process -FilePath "$game\arma3_x64.exe" -WorkingDirectory $game -ArgumentList $arguments -WindowStyle $windowStyle -PassThru
$process.Id | Set-Content (Join-Path $profile 'client.pid')
Write-Host "Isolated UI client PID $($process.Id). RPT: $profile"
