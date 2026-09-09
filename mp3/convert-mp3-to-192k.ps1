# MP3 파일 중 192kbps를 초과하는 파일만 192kbps로 변환하고 나머지는 그대로 유지합니다.

$ffmpeg = "C:\app\ffmpeg\bin\ffmpeg.exe"
$ffprobe = "C:\app\ffmpeg\bin\ffprobe.exe"

$outDir = "converted_192k"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

Get-ChildItem *.mp3 | ForEach-Object {

    $file = $_.FullName

    $bitrate = & $ffprobe -v error -select_streams a:0 `
        -show_entries stream=bit_rate `
        -of default=noprint_wrappers=1:nokey=1 "$file"

    $bitrateK = [int]($bitrate / 1000)

    if ($bitrateK -gt 192) {

        $outFile = Join-Path $outDir $_.Name

        & $ffmpeg -i "$file" -b:a 192k "$outFile"

        Write-Host "변환: $($_.Name) ($bitrateK → 192k)"
    }
    else {
        Write-Host "유지: $($_.Name) ($bitrateK)"
    }
}
