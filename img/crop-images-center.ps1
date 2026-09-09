# 이미지 파일만 추려서 중앙 기준으로 지정된 크기로 크롭
# 하위 폴더는 처리하지 않음
# 이미지 중앙을 기준으로 크롭
# 모든 결과를 JPG로 저장
# 메타데이터 제거
# 원본 이미지는 변경하지 않음
# 동일한 파일명이 있으면 _01, _02 형식으로 중복 방지
#
# 예:
# image.png → crop_1920x1080\image.jpg
# image.jpg → crop_1920x1080\image_01.jpg


$width = 1920
$height = 1080


# 출력 폴더
$outDir = "crop_${width}x${height}"

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

        $output = Join-Path $outDir "${fileName}.jpg"

        $index++

    } while (Test-Path -LiteralPath $output)


    # 중앙 기준으로 크롭하고 JPG로 저장
    # -auto-orient : 이미지 회전 정보 적용
    # -resize      : 지정 영역을 채우도록 확대/축소
    # -gravity     : 중앙 기준 설정
    # -extent      : 지정 크기로 정확하게 크롭
    # -strip       : 메타데이터 제거
    # -quality     : JPG 품질 설정
    magick "$input" `
        -auto-orient `
        -resize "${width}x${height}^" `
        -gravity center `
        -extent "${width}x${height}" `
        -strip `
        -quality 80 `
        "$output"


    Write-Host "완료: $($_.Name) → $fileName.jpg"
}


Write-Host "`n완료! 결과는 '$outDir' 폴더에 저장되었습니다."
