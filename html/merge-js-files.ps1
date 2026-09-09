# index.html에서 참조된 JS 파일을 HTML에 적힌 순서대로 하나의 merged.js 파일로 병합합니다.
# 외부 URL은 제외하고, 각 JS 파일의 전체 내용을 그대로 이어 붙입니다.

$html = [System.IO.File]::ReadAllText(
    ".\index.html",
    [System.Text.Encoding]::UTF8
)

$files = [regex]::Matches(
    $html,
    '<script[^>]+src=["'']([^"'']+)["''][^>]*>',
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
)

$output = ""

foreach ($match in $files) {

    $src = $match.Groups[1].Value

    # 외부 URL은 제외
    if ($src -match '^(https?:|//)') {
        continue
    }

    # 쿼리스트링 제거
    $src = $src -replace '\?.*$', ''

    # 경로 구분자 통일
    $src = $src.Replace("/", "\")

    if (Test-Path ".\$src") {

        $output += "`r`n/* ===== $src ===== */`r`n"

        $output += [System.IO.File]::ReadAllText(
            ".\$src",
            [System.Text.Encoding]::UTF8
        )

        $output += "`r`n"
    }
}

[System.IO.File]::WriteAllText(
    ".\merged.js",
    $output,
    [System.Text.UTF8Encoding]::new($false)
)
