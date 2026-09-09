# 이미지 파일만 추려서 WebP로 변환
# 하위 폴더는 처리하지 않음
# 가로 크기 기준으로 최대 크기까지 리사이즈
# 원본 이미지의 가로세로 비율 유지
# 메타데이터 제거
# WebP 품질 80
# 출력 파일은 원본 파일명을 사용
# 파일명이 겹칠 경우 _01, _02, _03 ... 추가
# 원본이 WebP인 경우에도 다시 변환
# 결과 파일은 resized-webp 폴더에 저장


$maxWidth = 1920
$outputDir = "resized-webp"


# 출력 폴더 생성
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null


# 현재 폴더의 이미지 파일만 처리
Get-ChildItem -File | Where-Object {
    $_.Extension -match '(?i)^\.(jpg|jpeg|png|gif|bmp|tiff|webp)$'
} | ForEach-Object {

    $file = $_
    $baseName = $file.BaseName


    # 기본 파일명
    $fileName = "${baseName}.webp"
    $outputPath = Join-Path $outputDir $fileName


    # 같은 이름이 있으면 _01, _02, _03... 추가
    $count = 1

    while (Test-Path -LiteralPath $outputPath) {

        $fileName = "${baseName}_{0:D2}.webp" -f $count

        $outputPath = Join-Path $outputDir $fileName

        $count++
    }


    # 가로 기준 리사이즈
    # 원본이 1920px보다 작으면 확대하지 않음
    # 메타데이터 제거
    # WebP 품질 80
    magick "$($file.FullName)" `
        -auto-orient `
        -resize "${maxWidth}x>" `
        -strip `
        -quality 80 `
        "$outputPath"


    # 변환 결과 확인
    if (Test-Path -LiteralPath $outputPath) {
        Write-Host "변환: $($file.Name) → $fileName"
    }
    else {
        Write-Host "변환 실패: $($file.Name)"
    }
}
