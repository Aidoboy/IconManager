$dir = [System.IO.Path]::GetFullPath((Join-Path $(([io.fileinfo]$MyInvocation.MyCommand.Definition).DirectoryName) "..\"))

Function Div([Parameter(Mandatory=$true)][double]$x, [Parameter(Mandatory=$true)][double]$y) { $x / $y }

invoke-expression -Command "$dir\bin\clean.ps1"

robocopy $dir\input $dir\output /e /xf *.*

$enablesvg = $TRUE
$enablepng = $TRUE

$filecount = 0
If($enablepng){
    Get-ChildItem -Path (Join-Path $dir input\) -Filter *.png -Recurse -File | Where-Object {$_.Name -match "[^\]]+.png"} | ForEach-Object {
        $filecount = $filecount + 1
    }
}
If($enablesvg){
    Get-ChildItem -Path (Join-Path $dir input\) -Filter *.svg -Recurse -File | ForEach-Object {
        $filecount = $filecount + 1
    }
}
Get-ChildItem -Path (Join-Path $dir input\) -Filter *.webp -Recurse -File | ForEach-Object {
    $filecount = $filecount + 1
}

$donecount = 0
If($enablepng){
    Get-ChildItem -Path (Join-Path $dir input\) -Filter *.png -Recurse -File | Where-Object {$_.Name -match "[^\]]+.png"} | ForEach-Object {
        Write-Progress -Activity "$(([io.fileinfo]$_).basename -replace "input", "output")" -Status "$((Div $donecount $filecount) * 100)% Complete:" -PercentComplete $((Div $donecount $filecount) * 100);
        invoke-expression -Command "$dir\bin\prepare.ps1 `"$($_.FullName)`" `"$(([io.fileinfo]$_).DirectoryName -replace "input", "output")`""
        $donecount = $donecount + 1
    }
}
If($enablesvg){
    Get-ChildItem -Path (Join-Path $dir input\) -Filter *.svg -Recurse -File | ForEach-Object {
        Write-Progress -Activity "$(([io.fileinfo]$_).basename -replace "input", "output")" -Status "$([math]::Round((Div $donecount $filecount) * 100))% Complete:" -PercentComplete $((Div $donecount $filecount) * 100);
        invoke-expression -Command "$dir\bin\prepare.ps1 `"$($_.FullName)`" `"$(([io.fileinfo]$_).DirectoryName -replace "input", "output")`""
        $donecount = $donecount + 1
    }
}
Get-ChildItem -Path (Join-Path $dir input\) -Filter *.webp -Recurse -File | ForEach-Object {
    Write-Progress -Activity "$(([io.fileinfo]$_).basename -replace "input", "output")" -Status "$([math]::Round((Div $donecount $filecount) * 100))% Complete:" -PercentComplete $((Div $donecount $filecount) * 100);
    invoke-expression -Command "$dir\bin\prepare.ps1 `"$($_.FullName)`" `"$(([io.fileinfo]$_).DirectoryName -replace "input", "output")`""
    $donecount = $donecount + 1
}