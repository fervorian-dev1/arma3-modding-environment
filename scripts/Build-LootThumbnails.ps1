param([string[]]$Names=@())
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=Split-Path $PSScriptRoot -Parent
$project=Join-Path $root 'projects\antistasi_support_services'
if($Names.Count -eq 0){$Names=@(Get-ChildItem (Join-Path $project 'art\loot') -Filter '*.png' -File | ForEach-Object {$_.BaseName})}
foreach($name in $Names) {
    $source=[Drawing.Image]::FromFile((Join-Path $project "art\loot\$name.png"))
    $bitmap=New-Object Drawing.Bitmap 256,256
    $graphics=[Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.Clear([Drawing.Color]::FromArgb(24,27,28))
        $graphics.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($source,0,0,256,256)
        $bitmap.Save((Join-Path $project "addons\dsds_support\ui\loot\$name.jpg"),[Drawing.Imaging.ImageFormat]::Jpeg)
    } finally {$graphics.Dispose();$bitmap.Dispose();$source.Dispose()}
}
