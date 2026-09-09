# index.html에서 참조된 CSS 파일만 HTML에 적힌 순서대로 병합하여 merged.css로 생성합니다.
# 하위 폴더의 CSS 파일도 상대경로를 기준으로 찾아 병합합니다.
# index.html이 있는 폴더에서 실행해야 합니다.
# 원본 CSS 파일은 유지하고 merged.css만 새로 생성합니다.

$root = Get-Location
$htmlPath = Join-Path $root "index.html"
$outputPath = Join-Path $root "merged.css"

# index.html 확인
if (-not (Test-Path $htmlPath)) {
    Write-Host "index.html을 찾을 수 없습니다."
    exit
}

$html = [System.IO.File]::ReadAllText(
    $htmlPath,
    [System.Text.Encoding]::UTF8
)

$files = [regex]::Matches(
    $html,
    '<link[^>]+href=["'']([^"'']+\.css(?:\?[^"'']*)?)["''][^>]*>',
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
)

$output = ""

foreach ($file in $files) {

    $cssRelativePath = $file.Groups[1].Value

    # 쿼리스트링 제거
    $cssRelativePath = $cssRelativePath -replace '\?.*$', ''

    # 외부 URL 제외
    if ($cssRelativePath -match '^(https?:|//|data:)') {
        continue
    }

    # 경로 구분자 통일
    $cssRelativePath = $cssRelativePath.Replace("/", "\")

    # ./ 제거
    while ($cssRelativePath.StartsWith(".\")) {
        $cssRelativePath = $cssRelativePath.Substring(2)
    }

    # HTML 기준 상대경로를 실제 파일 경로로 변환
    $cssPath = Join-Path $root $cssRelativePath

    if (Test-Path $cssPath -PathType Leaf) {

        $output += "`r`n/* ===== $cssRelativePath ===== */`r`n"

        $output += [System.IO.File]::ReadAllText(
            $cssPath,
            [System.Text.Encoding]::UTF8
        )

        $output += "`r`n"
    }
    else {
        Write-Host "파일을 찾을 수 없습니다: $cssRelativePath"
    }
}

[System.IO.File]::WriteAllText(
    $outputPath,
    $output,
    [System.Text.UTF8Encoding]::new($false)
)

Write-Host "CSS 병합 완료: merged.css"
