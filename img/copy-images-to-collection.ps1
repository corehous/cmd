# 이미지 파일만 추려서 복사
# 하위 폴더는 처리하지 않음
# 출력 폴더는 collection-img
# 출력 파일은 원본 파일명을 사용
# 파일명이 겹칠 경우 _01, _02, _03 ... 추가
# 원본 파일은 변환하지 않고 그대로 복사

$collectionDir = ".\collection-img"

New-Item -ItemType Directory -Force -Path $collectionDir | Out-Null

# 현재 폴더의 이미지 파일만 가져오기
Get-ChildItem -File | Where-Object {
    $_.Extension -match '(?i)^\.(jpg|jpeg|png|webp|gif|bmp|tiff|avif)$'
} | ForEach-Object {

    $file = $_
    $baseName = $file.BaseName
    $extension = $file.Extension

    # 기본 파일명
    $fileName = "$baseName$extension"
    $outputPath = Join-Path $collectionDir $fileName

    # 같은 이름이 있으면 _01, _02, _03...
    $count = 1

    while (Test-Path -LiteralPath $outputPath) {
        $fileName = "${baseName}_{0:D2}${extension}" -f $count
        $outputPath = Join-Path $collectionDir $fileName
        $count++
    }

    # 원본 그대로 복사
    Copy-Item -LiteralPath $file.FullName -Destination $outputPath

    if (Test-Path -LiteralPath $outputPath) {
        Write-Host "복사: $($file.Name) → $fileName"
    }
    else {
        Write-Host "복사 실패: $($file.Name)"
    }
}

Write-Host "`n복사 완료! → collection-img"
