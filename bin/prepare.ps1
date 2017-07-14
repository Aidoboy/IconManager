param([Parameter(Mandatory=$true)][string]$filepathin)

function SameImg([string]$file1, [string]$file2){
    $compareresult = magick compare -metric RMSE "$file1" "$file2" NULL: 2>&1
    $compareresult = $compareresult | Out-String

    return ($compareresult -Match "magick : 0 \(0\).*")
}

Function IIf($If, $Right, $Wrong) {If ($If) {$Right} Else {$Wrong}}

Try{
    $filepath = [System.IO.Path]::GetFullPath((Join-Path (pwd) $filepathin))
}Catch{#If (!(Test-Path $filepath)){
    $filepath = $filepathin
}
# echo $filepath

#$filename = $filepath.Substring(0, $filepath.Length - 4)
#$fileext = $filepath.Substring($filepath.Length - 4, 4)

$fileinfo = ([io.fileinfo]$filepath)
$filename = $fileinfo.basename
# echo $filename
$fileext = $fileinfo.Extension
# echo $fileinfo.Name
$filedir = $fileinfo.DirectoryName
# echo $filedir
# echo $fileinfo.FullName

#echo $filename $filepath $fileext

If($fileext -Match ".svg") {
    If (Test-Path "$filedir\$filename.png"){
        Remove-Item "$filedir\$filename.png"
    }
    "--export-png `"$filedir\$filename.png`" -w 512 `"$filedir\$filename.svg`"`nexit" | inkscape.exe --shell
    while (!(Test-Path "$filedir\$filename.png")) {
        # echo "$filedir\$filename.png" $(Test-Path "$filedir\$filename.png")
        Start-Sleep 1
    }
}
If($fileext -Match ".webp") {
    If (Test-Path "$filedir\$filename.png"){
        Remove-Item "$filedir\$filename.png"
    }
    magick convert "$filedir\$filename.webp" "PNG32:$filedir\$filename.png"
}

magick convert "$filedir\$filename.png" -trim "PNG32:$filedir\$filename[Magick].png"

If(SameImg "$filedir\$filename.png" "$filedir\$filename[Magick].png"){
    # echo "$filedir\$filename[Magick].png"
    Remove-Item -LiteralPath "$filedir\$filename[Magick].png"
    $namemod = ""
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
    echo "Already square"
    $squaremod = $namemod
}else{
    echo "Not square"
    $squaremod = "[Square]"
    $dimensions = [string]$size + "x" + [string]$size
    magick convert "$filedir\$filename$namemod.png" -background transparent -gravity center -resize $dimensions -extent $dimensions "PNG32:$filedir\$filename$squaremod.png"
}

# echo $png.Height
# echo $png.Width
# echo $png.PhysicalDimension
# echo $png.HorizontalResolution
# echo $png.VerticalResolution

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