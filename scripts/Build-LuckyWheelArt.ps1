$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=Split-Path $PSScriptRoot -Parent
$source=Join-Path $root 'projects\antistasi_support_services\addons\dsds_support'
$config=Get-Content -LiteralPath (Join-Path $source 'lucky.hpp') -Raw
$rows=[regex]::Matches($config,'class (\w+) \{label="[^"]+";kind="[^"]+";(?:amount=\d+;)?weight=(\d+);\}')
if($rows.Count -ne 8){throw 'Expected eight wheel rewards; update the diagram labels/colors for the new registry.'}
$colors=@('#563694','#ab4575','#307c71','#375ca0','#a43336','#67914e','#c5842d','#fff194')
$labels=@('1,000','2,500','10,000','HELLCAT','RAID','FREE SPIN','MYSTERY','')
$total=0;foreach($row in $rows){$total += [int]$row.Groups[2].Value}
$bitmap=New-Object Drawing.Bitmap 512,512
$graphics=[Drawing.Graphics]::FromImage($bitmap)
try {
 $graphics.SmoothingMode=[Drawing.Drawing2D.SmoothingMode]::AntiAlias
 $graphics.Clear([Drawing.Color]::Black)
 $angle=0.0
 for($i=0;$i -lt $rows.Count;$i++){
  $weight=[int]$rows[$i].Groups[2].Value;$span=360.0*$weight/$total
  $brush=New-Object Drawing.SolidBrush ([Drawing.ColorTranslator]::FromHtml($colors[$i]))
  $pen=New-Object Drawing.Pen ([Drawing.Color]::Gold),2
  $fontSize=if($weight -lt 600){10}else{15}
  $font=New-Object Drawing.Font 'Arial',$fontSize,([Drawing.FontStyle]::Bold)
  try {
   $graphics.FillPie($brush,16,16,480,480,[single]$angle,[single]$span)
   $graphics.DrawPie($pen,16,16,480,480,[single]$angle,[single]$span)
   $mid=($angle+$span/2)*[Math]::PI/180
   $size=$graphics.MeasureString($labels[$i],$font)
   $graphics.DrawString($labels[$i],$font,[Drawing.Brushes]::White,[single](256+160*[Math]::Cos($mid)-$size.Width/2),[single](256+160*[Math]::Sin($mid)-$size.Height/2))
  } finally {$font.Dispose();$pen.Dispose();$brush.Dispose()}
  $angle+=$span
 }
 $rim=New-Object Drawing.Pen ([Drawing.Color]::Goldenrod),9
 try {$graphics.DrawEllipse($rim,15,15,482,482)} finally {$rim.Dispose()}
 $graphics.FillEllipse([Drawing.Brushes]::Goldenrod,226,226,60,60)
 $bitmap.Save((Join-Path $source 'ui\lucky_wheel.jpg'),[Drawing.Imaging.ImageFormat]::Jpeg)
} finally {$graphics.Dispose();$bitmap.Dispose()}
