# merged.css의 분리되거나 깨진 CSS 문법을 복구하여 fixed.css로 저장합니다.
# 원본 merged.css는 유지하고 수정된 결과만 fixed.css에 생성합니다.

$inputFile = "merged.css"
$outputFile = "fixed.css"

# 파일 존재 확인
if (-not (Test-Path $inputFile)) {
    Write-Host "$inputFile 파일을 찾을 수 없습니다."
    exit
}

# CSS 전체 읽기
$css = Get-Content $inputFile -Raw -Encoding UTF8

# 1. 따옴표로 분리된 문자열 연결
# 예: "abc" + "def" → "abcdef"
# SVG Data URI 등 분리된 문자열 복구
$css = $css -replace '"\s*\+\s*"', ''

# 2. 하이픈 주변의 잘못된 공백 제거
# 예: swiper - slide → swiper-slide
#     - webkit - transform → -webkit-transform
#     background - image → background-image
$css = $css -replace '\s*-\s*', '-'

# 3. 숫자와 CSS 단위 사이의 공백 제거
# 예: 360 deg → 360deg
#     -40 px → -40px
#     3.75 rem → 3.75rem
#     .3 s → .3s
$css = $css -replace '(-?(?:\d+(?:\.\d+)?|\.\d+))\s+(px|em|rem|vh|vw|vmin|vmax|deg|rad|turn|ms|s|pt|pc|cm|mm|in|ch|ex)', '$1$2'

# 4. 숫자와 퍼센트 사이의 공백 제거
# 예: 100 % → 100%
#     -50 % → -50%
$css = $css -replace '(-?(?:\d+(?:\.\d+)?|\.\d+))\s+%', '$1%'

# 5. CSS 의사 선택자의 잘못된 공백 제거
# 예: : after → :after
#     :: before → ::before
$css = $css -replace '(:{1,2})\s+([a-zA-Z-]+)', '$1$2'

# 결과 저장
[System.IO.File]::WriteAllText(
    (Join-Path (Get-Location) $outputFile),
    $css,
    [System.Text.UTF8Encoding]::new($false)
)

Write-Host ""
Write-Host "CSS 문법 복구 완료!"
Write-Host "원본 : $inputFile"
Write-Host "수정본 : $outputFile"
