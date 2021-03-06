﻿param([Parameter(Mandatory=$true)][string]$srcfilein, [Parameter(Mandatory=$true)][string]$dest)

function SameImg([string]$file1, [string]$file2){
    $compareresult = magick compare -metric RMSE "$file1" "$file2" NULL: 2>&1
    $compareresult = $compareresult | Out-String

    return ($compareresult -Match "magick : 0 \(0\).*")
}

Function IIf($If, $Right, $Wrong) {If ($If) {$Right} Else {$Wrong}}

Try{
    $filepath = [System.IO.Path]::GetFullPath((Join-Path (pwd) $srcfilein))
}Catch{#If (!(Test-Path $filepath)){
    $srcfile = $srcfilein
}
# echo $filepath

#$filename = $filepath.Substring(0, $filepath.Length - 4)
#$fileext = $filepath.Substring($filepath.Length - 4, 4)

$srcinfo = ([io.fileinfo]$srcfile)
$srcname = $srcinfo.basename
# echo $filename
$srcext = $srcinfo.Extension
# echo $fileinfo.Name
$srcdir = $srcinfo.DirectoryName
# echo $filedir
# echo $fileinfo.FullName

#echo $filename $filepath $fileext

$namemod = "[Source]"

If($srcext -Match ".svg") {
    If (Test-Path "$dest\$srcname$namemod.png"){
        Remove-Item "$dest\$srcname$namemod.png"
    }
    "--export-png `"$dest\$srcname$namemod.png`" -w 512 `"$srcdir\$srcname.svg`"`nexit" | inkscape.exe --shell | out-null
    # echo "`"--export-png `"$dest\$srcname.png`" -w 512 `"$srcdir\$srcname.svg`"`nexit`" | inkscape.exe --shell"
    # echo  $($($namemod -replace "\[", "``[") -replace "\]", "``]")
    
    #while (!(Test-Path "$dest\$srcname$($($namemod -replace "\[", "``[") -replace "\]", "``]").png")) {
    #    Start-Sleep .5
    #}
    #Start-Sleep 5
}
ElseIf($srcext -Match ".webp") {
    If (Test-Path "$dest\$srcname$namemod.png"){
        Remove-Item "$dest\$srcname$namemod.png"
    }
    magick convert "$srcdir\$srcname.webp" "PNG32:$dest\$srcname$namemod.png"
}
Else{
    Copy-Item "$srcdir\$srcname.png" "$dest\$srcname$namemod.png"
}

$filename = $srcname
$filedir = $dest


magick convert "$filedir\$filename$namemod.png" -trim "PNG32:$filedir\$filename[Magick].png"

If(SameImg "$filedir\$filename$namemod.png" "$filedir\$filename[Magick].png"){
    # echo "$filedir\$filename[Magick].png"
    Remove-Item -LiteralPath "$filedir\$filename[Magick].png"
}Else{
    $namemod = "[Magick]"
}

add-type -AssemblyName System.Drawing
$png = New-Object System.Drawing.Bitmap "$filedir\$filename$namemod.png"

if($png.Height -gt $png.Width){
    $size = $png.Height
}else{
    $size = $png.Width
}

if($png.Height -eq $png.Width){
    # echo "Already square"
    $squaremod = $namemod
}else{
    # echo "Not square"
    $squaremod = "[Square]"
    $dimensions = [string]$size + "x" + [string]$size
    magick convert "$filedir\$filename$namemod.png" -background transparent -gravity center -resize $dimensions -extent $dimensions "PNG32:$filedir\$filename$squaremod.png"
}

# echo $png.Height
# echo $png.Width
# echo $png.PhysicalDimension
# echo $png.HorizontalResolution
# echo $png.VerticalResolution

$minBorder = 0;
$minResize = 1;
$resize = 2;
$extent = 3;
$gravity = 4;

$sizes = @{
    "Favicon"       = @("0",   "16",  "16x16",   "16x16",   "center");
    "Small"         = @("0",   "70",  "70x70",   "70x70",   "center");
    "Medium"        = @("70",  "150", "150x150", "150x150", "center");
    "Large"         = @("150", "310", "310x310", "310x310", "center");
    "Wide"          = @("70",  "150", "310x150", "310x150", "center");
    "Wide2"         = @("150", "310", "310",     "310x150", "center");
    "Wide3"         = @("150", "310", "310",     "310x150", "north");
    "BorderSmall"   = @("0",   "63",  "63x63",   "70x70",   "center");
    "BorderMedium"  = @("63",  "135", "135x135", "150x150", "center");
    "BorderLarge"   = @("135", "279", "279x279", "310x310", "center");
    "BorderWide"    = @("63",  "135", "279x135", "310x150", "center");
    "BorderWide2"   = @("135", "279", "279",     "310x150", "center");
    "BorderWide3"   = @("135", "279", "279",     "310x150", "north");
}

$sizes.keys | % {
    $key = $_
    $value = $sizes.Item($key)
    #echo $key $value
    #echo "Size: " $size $value[$minResize]
    #echo $($size -ge $value[$minResize])
    if($size -ge $value[$minResize]){
        magick convert "$filedir\$filename$namemod.png" -background transparent -gravity $value[$gravity] -resize $value[$resize] -filter lanczos -extent $value[$extent] "PNG32:$filedir\$filename[$key].png"
    }elseif($size -ge $value[$minBorder]){
        magick convert "$filedir\$filename$namemod.png" -background transparent -gravity $value[$gravity]                                         -extent $value[$extent] "PNG32:$filedir\$filename[$key].png"
    }
}

If(SameImg "$filedir\$filename[Wide].png" "$filedir\$filename[Wide2].png"){
    Remove-Item -LiteralPath "$filedir\$filename[Wide2].png"
}
If(SameImg "$filedir\$filename[BorderWide].png" "$filedir\$filename[BorderWide2].png"){
    Remove-Item -LiteralPath "$filedir\$filename[BorderWide2].png"
}
If(SameImg "$filedir\$filename[Wide].png" "$filedir\$filename[Wide3].png"){
    Remove-Item -LiteralPath "$filedir\$filename[Wide3].png"
}
If(SameImg "$filedir\$filename[BorderWide].png" "$filedir\$filename[BorderWide3].png"){
    Remove-Item -LiteralPath "$filedir\$filename[BorderWide3].png"
}

$icosizes = ""
@(256,192,128,96,64,48,32,24) | Foreach-Object {
    if($_ -le $size){
        $icosizes += $_
        $icosizes += ","
    }
}
$icosizes += "16"
magick convert "$filedir\$filename$squaremod.png" -define icon:auto-resize=$icosizes "$filedir\$filename.ico"

<#
if($size -gt 70){
    magick convert "$filedir\$filename$namemod.png" -background transparent -gravity center -resize 70x70 -extent 70x70 "PNG32:$filedir\$filename[Small].png"
    if($size -gt 150){
        magick convert "$filedir\$filename$namemod.png" -background transparent -gravity center -resize 150x150 -extent 150x150 "PNG32:$filedir\$filename[Medium].png"
        magick convert "$filedir\$filename$namemod.png" -background transparent -gravity center -resize 310x150 -extent 310x150 "PNG32:$filedir\$filename[Wide].png"
        if($size -gt 310){
            magick convert "$filedir\$filename$namemod.png" -background transparent -gravity center -resize 310x310 -extent 310x310 "PNG32:$filedir\$filename[Large].png"
            magick convert "$filedir\$filename$namemod.png" -background transparent -gravity center -resize 310 -extent 310x150 "PNG32:$filedir\$filename[Wide2].png"

            If(SameImg "$filedir\$filename[Wide].png" "$filedir\$filename[Wide2].png"){
                Remove-Item -LiteralPath "$filedir\$filename[Wide2].png"
            }
        }else{
            magick convert "$filedir\$filename$namemod.png" -background transparent -gravity center -extent 310x310 "PNG32:$filedir\$filename[Large].png"
        }
    }else{
        magick convert "$filedir\$filename$namemod.png" -background transparent -gravity center -extent 150x150 "PNG32:$filedir\$filename[Medium].png"
    }
}else{
    magick convert "$filedir\$filename$namemod.png" -background transparent -gravity center -extent 70x70 "PNG32:$filedir\$filename[Small].png"
}

$icosizes = ""
@(256,192,128,96,64,48,32,24) | Foreach-Object {
    if($_ -le $size){
        $icosizes += $_
        $icosizes += ","
    }
}
$icosizes += "16"
magick convert "$filedir\$filename$squaremod.png" -define icon:auto-resize=$icosizes "$filedir\$filename.ico"
#>