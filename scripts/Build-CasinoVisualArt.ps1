$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=Split-Path $PSScriptRoot -Parent
$ui=Join-Path $root 'projects\antistasi_support_services\addons\dsds_support\ui'
$art=Join-Path $root 'temp\casino54-art'
New-Item -ItemType Directory -Force $art | Out-Null
function Draw-Asset($name,$draw){
 $b=New-Object Drawing.Bitmap 1024,1024;$g=[Drawing.Graphics]::FromImage($b)
 try{$g.SmoothingMode='AntiAlias';$g.Clear([Drawing.Color]::Transparent);& $draw $g;$b.Save((Join-Path $art ($name+'.png')),[Drawing.Imaging.ImageFormat]::Png)}finally{$g.Dispose();$b.Dispose()}
 Push-Location 'A:\SteamLibrary\steamapps\common\Arma 3 Tools\ImageToPAA'
 try{& .\ImageToPAA.exe (Join-Path $art ($name+'.png')) (Join-Path $ui ($name+'.paa'));if($LASTEXITCODE -ne 0){throw 'PAA conversion failed'}}finally{Pop-Location}
}
Draw-Asset 'roulette_wheel_ca' {
 param($g)
 $g.FillEllipse([Drawing.Brushes]::SaddleBrown,10,10,1004,1004)
 $gold=New-Object Drawing.Pen ([Drawing.Color]::Goldenrod),12
 $g.DrawEllipse($gold,18,18,988,988)
 $order=@(0,32,15,19,4,21,2,25,17,34,6,27,13,36,11,30,8,23,10,5,24,16,33,1,20,14,31,9,22,18,29,7,28,12,35,3,26)
 $red=@(1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36)
 $font=New-Object Drawing.Font 'Arial',22,([Drawing.FontStyle]::Bold)
 $thin=New-Object Drawing.Pen ([Drawing.Color]::Goldenrod),2
 for($i=0;$i -lt 37;$i++){
  $n=$order[$i];$brush=if($n -eq 0){[Drawing.Brushes]::DarkGreen}elseif($red -contains $n){[Drawing.Brushes]::Firebrick}else{[Drawing.Brushes]::Black}
  $a=-90+360*$i/37;$span=360/37
  $g.FillPie($brush,95,95,834,834,[single]($a-$span/2),[single]$span)
  $g.DrawPie($thin,95,95,834,834,[single]($a-$span/2),[single]$span)
  $r=$a*[Math]::PI/180;$size=$g.MeasureString([string]$n,$font)
  $g.DrawString([string]$n,$font,[Drawing.Brushes]::Ivory,[single](512+370*[Math]::Cos($r)-$size.Width/2),[single](512+370*[Math]::Sin($r)-$size.Height/2))
 }
 $g.FillEllipse([Drawing.Brushes]::SaddleBrown,250,250,524,524);$g.DrawEllipse($gold,250,250,524,524)
 $g.FillEllipse([Drawing.Brushes]::DarkGreen,340,340,344,344);$g.DrawEllipse($gold,340,340,344,344)
 $g.FillEllipse([Drawing.Brushes]::Goldenrod,460,460,104,104)
 $font.Dispose();$gold.Dispose();$thin.Dispose()
}
Draw-Asset 'roulette_ball_ca' {param($g);$g.FillEllipse([Drawing.Brushes]::Gray,60,70,910,910);$g.FillEllipse([Drawing.Brushes]::Ivory,30,30,910,910);$g.FillEllipse([Drawing.Brushes]::White,190,140,250,200)}
Draw-Asset 'roulette_chip_ca' {param($g);$g.FillEllipse([Drawing.Brushes]::Goldenrod,20,20,984,984);$g.FillEllipse([Drawing.Brushes]::Firebrick,90,90,844,844);$p=New-Object Drawing.Pen ([Drawing.Color]::Ivory),30;$g.DrawEllipse($p,170,170,684,684);$p.Dispose();$f=New-Object Drawing.Font 'Arial',210,([Drawing.FontStyle]::Bold);$g.DrawString('$',$f,[Drawing.Brushes]::Ivory,340,310);$f.Dispose()}
