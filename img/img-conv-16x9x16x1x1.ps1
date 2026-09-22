# ============================================
# 이미지 비율별 중앙 크롭
# 16:9 / 1:1 / 9:16
# 확대/축소 없음
# 원본 파일명 유지
# ============================================


# --------------------------------------------
# 출력 폴더 생성
# --------------------------------------------

$folders = @("16x9", "1x1", "9x16")

foreach ($folder in $folders) {

    $outputFolder = Join-Path (Get-Location) $folder

    if (-not (Test-Path $outputFolder)) {
        New-Item -ItemType Directory -Path $outputFolder | Out-Null
    }
}


# --------------------------------------------
# 현재 폴더의 이미지 처리
# --------------------------------------------

Get-ChildItem -File | Where-Object {
    $_.Extension -match '\.(jpg|jpeg|png|webp)$'
} | Sort-Object Name | ForEach-Object {

    $input = $_.FullName

    # 원본 이미지 크기 확인
    $size = magick identify -format "%w %h" "$input"
    $wh = $size -split " "

    $width  = [int]$wh[0]
    $height = [int]$wh[1]


    # ============================================
    # 16:9
    # ============================================

    if ($width / $height -gt (16 / 9)) {

        # 가로가 긴 경우 → 좌우 크롭
        $cropWidth  = [math]::Floor($height * 16 / 9)
        $cropHeight = $height

    } else {

        # 세로가 긴 경우 → 위아래 크롭
        $cropWidth  = $width
        $cropHeight = [math]::Floor($width * 9 / 16)
    }

    $outputFolder = Join-Path (Get-Location) "16x9"
    $output = Join-Path $outputFolder $_.Name

    magick "$input" `
        -gravity center `
        -crop "${cropWidth}x${cropHeight}+0+0" `
        +repage `
        -strip `
        "$output"

    Write-Host "16:9  $($_.Name) → ${cropWidth}x${cropHeight}"


    # ============================================
    # 1:1
    # ============================================

    if ($width -gt $height) {

        # 가로가 긴 경우 → 좌우 크롭
        $cropWidth  = $height
        $cropHeight = $height

    } else {

        # 세로가 긴 경우 → 위아래 크롭
        $cropWidth  = $width
        $cropHeight = $width
    }

    $outputFolder = Join-Path (Get-Location) "1x1"
    $output = Join-Path $outputFolder $_.Name

    magick "$input" `
        -gravity center `
        -crop "${cropWidth}x${cropHeight}+0+0" `
        +repage `
        -strip `
        "$output"

    Write-Host "1:1   $($_.Name) → ${cropWidth}x${cropHeight}"


    # ============================================
    # 9:16
    # ============================================

    if ($width / $height -gt (9 / 16)) {

        # 가로가 긴 경우 → 좌우 크롭
        $cropWidth  = [math]::Floor($height * 9 / 16)
        $cropHeight = $height

    } else {

        # 세로가 긴 경우 → 위아래 크롭
        $cropWidth  = $width
        $cropHeight = [math]::Floor($width * 16 / 9)
    }

    $outputFolder = Join-Path (Get-Location) "9x16"
    $output = Join-Path $outputFolder $_.Name

    magick "$input" `
        -gravity center `
        -crop "${cropWidth}x${cropHeight}+0+0" `
        +repage `
        -strip `
        "$output"

    Write-Host "9:16  $($_.Name) → ${cropWidth}x${cropHeight}"

}
