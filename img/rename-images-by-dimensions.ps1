# 이미지 파일만 추려서 파일명을 가로x세로x랜덤4자리 숫자로 변경
# 하위 폴더는 처리하지 않음
# 이미지 내용과 파일 형식은 그대로 유지
# 파일명은 가로x세로x랜덤4자리 숫자.확장자 형식으로 생성
# 파일명 중복 방지
# 결과 파일은 renamed 폴더에 저장


$outputDir = "renamed"


# 결과 폴더 생성
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null


# 랜덤 4자리 숫자 생성
function Get-RandomDigits {
    return (Get-Random -Minimum 0 -Maximum 10000).ToString("0000")
}


# 현재 폴더의 이미지 파일만 처리
Get-ChildItem -File | Where-Object {
    $_.Extension -match '(?i)^\.(jpg|jpeg|png|webp|gif|bmp|tiff|avif)$'
} | ForEach-Object {

    $file = $_


    # ImageMagick으로 이미지 실제 크기 확인
    $info = (magick identify -format "%w %h" "$($file.FullName)").Trim()

    $w, $h = $info -split "\s+"


    # 파일명 생성
    do {
        $rand = Get-RandomDigits

        $fileName = "${w}x${h}x${rand}$($file.Extension.ToLower())"

        $outputPath = Join-Path $outputDir $fileName
    }
    while (Test-Path -LiteralPath $outputPath)


    # 원본 파일 그대로 복사
    Copy-Item -LiteralPath $file.FullName -Destination $outputPath


    Write-Host "복사: $($file.Name) → $fileName"
}


Write-Host "`n완료! 결과는 '$outputDir' 폴더에 저장되었습니다."
