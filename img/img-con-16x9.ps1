# 16x9 폴더 생성
$outputFolder = Join-Path (Get-Location) "16x9"

if (-not (Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

# 현재 폴더의 이미지 처리
Get-ChildItem -File | Where-Object {
    $_.Extension -match '\.(jpg|jpeg|png|webp)$'
} | Sort-Object Name | ForEach-Object {

    $input = $_.FullName
    $output = Join-Path $outputFolder $_.Name

    # 원본 이미지 크기 확인
    $size = magick identify -format "%w %h" "$input"
    $wh = $size -split " "

    $width  = [int]$wh[0]
    $height = [int]$wh[1]

    # 16:9 크롭 영역 계산
    if ($width / $height -gt (16 / 9)) {

        # 가로가 긴 경우 → 좌우 크롭
        $cropWidth  = [math]::Floor($height * 16 / 9)
        $cropHeight = $height

    } else {

        # 세로가 긴 경우 → 위아래 크롭
        $cropWidth  = $width
        $cropHeight = [math]::Floor($width * 9 / 16)
    }

    # 확대/축소 없이 중앙 크롭
    magick "$input" `
        -gravity center `
        -crop "${cropWidth}x${cropHeight}+0+0" `
        +repage `
        -strip `
        "$output"

    Write-Host "$($_.Name)  →  ${cropWidth}x${cropHeight}"
}
