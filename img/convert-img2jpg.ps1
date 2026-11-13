# 이미지 파일만 추려서 JPG로 변환
# 하위 폴더는 처리하지 않음
# 이미지 크기는 변경하지 않음
# 출력 파일은 원본 파일명을 사용
# 파일명이 겹칠 경우 _01, _02, _03 ... 추가
# 원본이 JPG인 경우에도 다시 변환
# 메타데이터 제거
# JPG 품질 80
# 결과 파일은 converted-jpg 폴더에 저장


$jpgBaseDir = "converted-jpg"


# 출력 폴더 생성
New-Item -ItemType Directory -Force -Path $jpgBaseDir | Out-Null


# 현재 폴더의 이미지 파일만 처리
Get-ChildItem -File | Where-Object {
    $_.Extension -match '(?i)^\.(jpg|jpeg|png|gif|bmp|tiff|webp)$'
} | ForEach-Object {

    $file = $_
    $baseName = $file.BaseName


    # 기본 파일명
    $fileName = "${baseName}.jpg"
    $jpgPath = Join-Path $jpgBaseDir $fileName


    # 같은 이름이 있으면 _01, _02, _03... 추가
    $count = 1

    while (Test-Path -LiteralPath $jpgPath) {

        $fileName = "${baseName}_{0:D2}.jpg" -f $count

        $jpgPath = Join-Path $jpgBaseDir $fileName

        $count++
    }


    # JPG 변환
    # 이미지 크기는 변경하지 않음
    # 자동 회전 적용
    # 메타데이터 제거
    # JPG 품질 80
    magick "$($file.FullName)" `
        -auto-orient `
        -strip `
        -quality 80 `
        "$jpgPath"


    # 변환 결과 확인
    if (Test-Path -LiteralPath $jpgPath) {
        Write-Host "변환: $($file.Name) → $fileName"
    }
    else {
        Write-Host "변환 실패: $($file.Name)"
    }
}


Write-Host "`n완료! JPG 파일이 '$jpgBaseDir' 폴더에 저장되었습니다."
