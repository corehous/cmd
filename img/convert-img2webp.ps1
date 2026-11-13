# 이미지 파일만 추려서 WebP로 변환
# 하위 폴더는 처리하지 않음
# 이미지 크기는 변경하지 않음
# 출력 파일은 원본 파일명을 사용
# 파일명이 겹칠 경우 _01, _02, _03 ... 추가
# 원본이 WebP인 경우에도 다시 변환
# 메타데이터 제거
# WebP 품질 80
# 결과 파일은 webp 폴더에 저장


$webpBaseDir = "webp"


# 출력 폴더 생성
New-Item -ItemType Directory -Force -Path $webpBaseDir | Out-Null


# 현재 폴더의 이미지 파일만 가져오기
$files = Get-ChildItem -File | Where-Object {
    $_.Extension -match '(?i)^\.(jpg|jpeg|png|gif|bmp|tiff|webp)$'
}


foreach ($file in $files) {

    $baseName = $file.BaseName


    # 기본 파일명
    $fileName = "${baseName}.webp"
    $webpPath = Join-Path $webpBaseDir $fileName


    # 같은 이름이 있으면 _01, _02, _03... 추가
    $count = 1

    while (Test-Path -LiteralPath $webpPath) {

        $fileName = "${baseName}_{0:D2}.webp" -f $count

        $webpPath = Join-Path $webpBaseDir $fileName

        $count++
    }


    # WebP 변환
    # 이미지 크기는 변경하지 않음
    # 자동 회전 적용
    # 메타데이터 제거
    # WebP 품질 80
    magick "$($file.FullName)" `
        -auto-orient `
        -strip `
        -quality 80 `
        "$webpPath"


    # 변환 결과 확인
    if (Test-Path -LiteralPath $webpPath) {
        Write-Host "변환: $($file.Name) → $fileName"
    }
    else {
        Write-Host "변환 실패: $($file.Name)"
    }
}
