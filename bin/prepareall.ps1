# echo "XXX" $MyInvocation.MyCommand.Definition "XXX"
$dir = ([io.fileinfo]$MyInvocation.MyCommand.Definition).DirectoryName
# echo "XXX" $dir "XXX"

Get-ChildItem -Path .\ -Filter *.png -Recurse -File | Where-Object {$_.Name -match "[^\]]+.png"} | ForEach-Object {
    invoke-expression -Command "$dir\prepare.ps1 $($_.FullName)"
}

Get-ChildItem -Path .\ -Filter *.svg -Recurse -File | ForEach-Object {
    invoke-expression -Command "$dir\prepare.ps1 $($_.FullName)"
}

Get-ChildItem -Path .\ -Filter *.webp -Recurse -File | ForEach-Object {
    invoke-expression -Command "$dir\prepare.ps1 $($_.FullName)"
}