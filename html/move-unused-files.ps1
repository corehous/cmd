# 현재 폴더의 index.html과 사용 중인 CSS를 기준으로 사용되지 않는 파일을 unused 폴더로 이동합니다.
# HTML의 src / href / url() 및 참조된 CSS 내부의 url()을 검사합니다.

$root = Get-Location
$htmlPath = Join-Path $root "index.html"
$unusedDir = Join-Path $root "unused"

if (-not (Test-Path $htmlPath)) {
    Write-Host "index.html을 찾을 수 없습니다."
    exit
}

if (-not (Test-Path $unusedDir)) {
    New-Item -ItemType Directory -Path $unusedDir | Out-Null
}

$usedFiles = New-Object System.Collections.Generic.HashSet[string](
    [System.StringComparer]::OrdinalIgnoreCase
)

$usedFiles.Add("index.html") | Out-Null

function Get-FileNameFromReference {
    param (
        [string]$Reference
    )

    $file = $Reference.Trim()

    if ([string]::IsNullOrWhiteSpace($file)) {
        return $null
    }

    if ($file -match '^(https?:|//|data:|#|mailto:|javascript:|tel:)') {
        return $null
    }

    $file = $file -replace '\?.*$', ''
    $file = $file -replace '#.*$', ''
    $file = $file.Trim('"', "'")
    $file = $file.Replace("/", "\")

    while ($file.StartsWith(".\")) {
        $file = $file.Substring(2)
    }

    while ($file.StartsWith("..\")) {
        $file = $file.Substring(3)
    }

    $fileName = Split-Path $file -Leaf

    if ([string]::IsNullOrWhiteSpace($fileName)) {
        return $null
    }

    return $fileName
}

$html = Get-Content $htmlPath -Raw -Encoding UTF8

$htmlMatches = [regex]::Matches(
    $html,
    '(?:src|href)\s*=\s*["'']([^"'']+)["'']',
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
)

foreach ($match in $htmlMatches) {

    $fileName = Get-FileNameFromReference $match.Groups[1].Value

    if ($fileName) {
        $usedFiles.Add($fileName) | Out-Null
    }
}

$htmlUrlMatches = [regex]::Matches(
    $html,
    'url\s*\(\s*["'']?([^)"'']+)["'']?\s*\)',
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
)

foreach ($match in $htmlUrlMatches) {

    $fileName = Get-FileNameFromReference $match.Groups[1].Value

    if ($fileName) {
        $usedFiles.Add($fileName) | Out-Null
    }
}

$cssFiles = Get-ChildItem $root -File -Filter *.css

foreach ($css in $cssFiles) {

    if (-not $usedFiles.Contains($css.Name)) {
        continue
    }

    $cssText = Get-Content $css.FullName -Raw -Encoding UTF8

    $urlMatches = [regex]::Matches(
        $cssText,
        'url\s*\(\s*["'']?([^)"'']+)["'']?\s*\)',
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )

    foreach ($match in $urlMatches) {

        $fileName = Get-FileNameFromReference $match.Groups[1].Value

        if ($fileName) {
            $usedFiles.Add($fileName) | Out-Null
        }
    }
}

$files = Get-ChildItem $root -File

foreach ($file in $files) {

    if ($file.Name -ieq "index.html") {
        continue
    }

    if ($file.Name -ieq $MyInvocation.MyCommand.Name) {
        continue
    }

    if ($usedFiles.Contains($file.Name)) {
        continue
    }

    Move-Item $file.FullName $unusedDir -Force

    Write-Host "이동: $($file.Name)"
}
