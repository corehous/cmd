# 현재 폴더의 모든 CSS 파일에서 @font-face와 font-family 선언을 제거합니다.
# 원본 CSS 파일을 직접 수정합니다.

Get-ChildItem -File -Filter "*.css" | ForEach-Object {

    $css = Get-Content $_.FullName -Raw -Encoding UTF8

    # @font-face { ... } 블록 전체 제거
    $css = $css -replace '(?is)@font-face\s*\{.*?\}', ''

    # font-family: ...; 선언 제거
    $css = $css -replace '(?is)\s*font-family\s*:\s*[^;{}]+;', ''

    # 수정된 CSS 저장
    [System.IO.File]::WriteAllText(
        $_.FullName,
        $css,
        [System.Text.UTF8Encoding]::new($false)
    )

    Write-Host "처리 완료: $($_.Name)"
}
