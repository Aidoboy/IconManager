$dir = ([io.fileinfo]$MyInvocation.MyCommand.Definition).DirectoryName

Get-ChildItem -Path .\ -Filter *.png -Recurse -File | Where-Object {$_.Name -match ".+[\]]+.png"} | ForEach-Object {
    # echo "$($_.FullName) $($_ | Test-Path)"
    $_ | Remove-Item
    # echo "$($_.FullName) $($_ | Test-Path)"
}

Get-ChildItem -Path .\ -Filter *.png -Recurse -File | ForEach-Object {
    If (Test-Path "$($_.DirectoryName)\$($_.basename).ico"){
        Remove-Item "$($_.DirectoryName)\$($_.basename).ico"
    }
}

Get-ChildItem -Path .\ -Filter *.svg -Recurse -File | ForEach-Object {
    If (Test-Path "$($_.DirectoryName)\$($_.basename).png"){
        Remove-Item "$($_.DirectoryName)\$($_.basename).png"
    }
}

Get-ChildItem -Path .\ -Filter *.webp -Recurse -File | ForEach-Object {
    If (Test-Path "$($_.DirectoryName)\$($_.basename).png"){
        Remove-Item "$($_.DirectoryName)\$($_.basename).png"
    }
}