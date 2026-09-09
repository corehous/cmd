# MP3 파일의 메타데이터를 제거하고 음질은 그대로 유지합니다.

$ffmpeg = "C:\ffmpeg\bin\ffmpeg.exe"

Get-ChildItem *.mp3 | ForEach-Object {

    $original = $_.FullName
    $temp = "$($_.DirectoryName)\__temp__$($_.Name)"

    & $ffmpeg -i "$original" -map_metadata -1 -c:a copy "$temp" -y

    if (Test-Path $temp) {
        Remove-Item "$original" -Force
        Rename-Item "$temp" $_.Name
        Write-Host "완료: $($_.Name)"
    }
    else {
        Write-Host "실패: $($_.Name)"
    }
}
