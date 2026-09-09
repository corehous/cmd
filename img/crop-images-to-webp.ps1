# 이미지 파일만 추려서 중앙 기준으로 지정된 크기로 크롭
# 하위 폴더는 처리하지 않음
# 이미지 중앙을 기준으로 크롭
# 모든 결과를 WebP로 저장
# 메타데이터 제거
# 원본 이미지는 변경하지 않음
# 동일한 파일명이 있으면 _01, _02, _03 ... 추가
# 결과 파일은 webp_가로x세로 폴더에 저장
#
# 예:
# image.jpg → webp_1920x1080\image.webp
# image.png → webp_1920x1080\image.webp
# image.webp → webp_1920x1080\image.webp


$width = 1920
$height = 1080


# 출력 폴더
$outDir = "webp_${width}x${height}"

New-Item -ItemType Directory -Force -Path $outDir | Out-Null


# 현재 폴더의 이미지 파일만 처리
Get-ChildItem -File | Where-Object {
    $_.Extension -match '(?i)^\.(jpg|jpeg|png|bmp|tiff|webp)$'
} | ForEach-Object {

    $input = $_.FullName
    $baseName = $_.BaseName


    # 중복 파일명 처리
    $index = 0

    do {

        if ($index -eq 0) {
            $fileName = $baseName
        }
        else {
            $fileName = "${baseName}_{0:D2}" -f $index
        }

        $output = Join-Path $outDir "${fileName}.webp"

        $index++

    } while (Test-Path -LiteralPath $output)


    # 중앙 기준으로 크롭하여 WebP 생성
    # -auto-orient : 이미지 회전 정보 적용
    # -resize      : 지정 영역을 채우도록 확대/축소
    # -gravity     : 중앙 기준 설정
    # -extent      : 지정 크기로 정확하게 크롭
    # -strip       : 메타데이터 제거
    # -quality     : WebP 품질 설정
    magick "$input" `
        -auto-orient `
        -resize "${width}x${height}^" `
        -gravity center `
        -extent "${width}x${height}" `
        -strip `
        -quality 80 `
        "$output"


    Write-Host "완료: $($_.Name) → $fileName.webp"
}
