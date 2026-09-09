# 이미지 파일만 추려서 지정된 비율(%)로 리사이즈
# 하위 폴더는 처리하지 않음
# 원본 이미지의 가로세로 비율을 그대로 유지
# 지정한 비율에 따라 작은 이미지도 확대
# 원본 파일 형식 그대로 유지
# 파일명은 리사이즈 후 실제크기x실제크기x랜덤4자리 숫자로 생성
# 파일명 중복 방지
# 결과 파일은 새 폴더에 저장
#
# 예:
# 원본 1200x800, 150% → 1800x1200x4837.jpg
# 원본 800x600, 50%  → 400x300x1024.png


$scale = 150


# 출력 폴더
$outDir = "resized_${scale}pct"

New-Item -ItemType Directory -Force -Path $outDir | Out-Null


# 랜덤 4자리 숫자 생성
function Get-RandomDigits {
    return (Get-Random -Minimum 0 -Maximum 10000).ToString("0000")
}


# 중복 방지
$usedNames = @{}


# 이미지 처리
Get-ChildItem -File | Where-Object {
    $_.Extension -match '(?i)^\.(jpg|jpeg|png|webp|bmp|tiff)$'
} | ForEach-Object {

    $input = $_.FullName
    $ext = $_.Extension.ToLower()


    # 임시 파일 생성
    $tempFile = "$env:TEMP\temp_$([guid]::NewGuid())$ext"


    # 지정한 비율(%)로 리사이즈
    # 작은 이미지도 지정한 비율까지 확대
    magick "$input" `
        -auto-orient `
        -resize "${scale}%" `
        "$tempFile"


    # 변환 실패 확인
    if (!(Test-Path -LiteralPath $tempFile)) {
        Write-Host "변환 실패: $($_.Name)"
        return
    }


    # 리사이즈된 이미지의 실제 크기 확인
    $info = (magick identify -format "%w %h" "$tempFile").Trim()
    $w, $h = $info -split "\s+"


    # 실제 크기 + 랜덤 4자리 숫자로 파일명 생성
    do {
        $rand = Get-RandomDigits

        $fileName = "${w}x${h}x${rand}${ext}"

        $output = Join-Path $outDir $fileName

    } while (
        ($usedNames.ContainsKey($fileName)) -or
        (Test-Path -LiteralPath $output)
    )


    $usedNames[$fileName] = $true


    # 임시 파일을 최종 위치로 이동
    Move-Item -LiteralPath $tempFile -Destination $output


    Write-Host "완료: $($_.Name) → $fileName"
}


Write-Host "`n완료! 결과는 '$outDir' 폴더에 저장되었습니다."
