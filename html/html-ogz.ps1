# 현재 폴더의 CSS, JS, 이미지 파일을 css/js/images 폴더로 분류하고 HTML/CSS의 로컬 경로를 수정

$Root = (Get-Location).Path

$HtmlFiles = Get-ChildItem -Path $Root -Filter "*.html" -File
$CssFiles = Get-ChildItem -Path $Root -Filter "*.css" -File
$JsFiles = Get-ChildItem -Path $Root -Filter "*.js" -File

$ImageExtensions = @(
    ".jpg",
    ".jpeg",
    ".png",
    ".gif",
    ".webp",
    ".svg",
    ".avif",
    ".ico",
    ".bmp",
    ".tif",
    ".tiff"
)

$ImageFiles = Get-ChildItem -Path $Root -File | Where-Object {
    $ImageExtensions -contains $_.Extension.ToLower()
}

$Folders = @("css", "js", "images")

foreach ($Folder in $Folders) {
    $FolderPath = Join-Path $Root $Folder

    if (-not (Test-Path $FolderPath)) {
        New-Item -ItemType Directory -Path $FolderPath | Out-Null
        Write-Host "폴더 생성: $Folder"
    }
}

$FileMap = @{}

foreach ($File in $CssFiles) {
    $FileMap[$File.Name] = "css/$($File.Name)"
}

foreach ($File in $JsFiles) {
    $FileMap[$File.Name] = "js/$($File.Name)"
}

foreach ($File in $ImageFiles) {
    $FileMap[$File.Name] = "images/$($File.Name)"
}

foreach ($HtmlFile in $HtmlFiles) {

    $Content = Get-Content $HtmlFile.FullName -Raw -Encoding UTF8

    foreach ($FileName in $FileMap.Keys) {

        $NewPath = $FileMap[$FileName]
        $EscapedFileName = [regex]::Escape($FileName)

        $Content = [regex]::Replace(
            $Content,
            "(?i)(src|href)(\s*=\s*[""'])((?:\./)?(?:/)?$EscapedFileName)([""'])",
            "`$1`$2$NewPath`$4"
        )

        $Content = [regex]::Replace(
            $Content,
            "(?i)(src|href)(\s*=\s*[""'])((?:\./)?(?:/)?(?:[^""']*/)?$EscapedFileName)([""'])",
            {
                param($Match)

                $Original = $Match.Groups[3].Value

                if ($Original -match '^(https?:)?//') {
                    return $Match.Value
                }

                if ($Original -match '^/?(?:css|js|images)/') {
                    return $Match.Value
                }

                return $Match.Groups[1].Value +
                       $Match.Groups[2].Value +
                       $NewPath +
                       $Match.Groups[4].Value
            }
        )
    }

    Set-Content $HtmlFile.FullName -Value $Content -Encoding UTF8

    Write-Host "HTML 수정: $($HtmlFile.Name)"
}

foreach ($CssFile in $CssFiles) {

    $Content = Get-Content $CssFile.FullName -Raw -Encoding UTF8

    foreach ($FileName in $FileMap.Keys) {

        $NewPath = $FileMap[$FileName]

        if ($NewPath -like "images/*") {
            $CssPath = "../$NewPath"
        }
        elseif ($NewPath -like "css/*") {
            $CssPath = "../$NewPath"
        }
        else {
            continue
        }

        $EscapedFileName = [regex]::Escape($FileName)

        $Content = [regex]::Replace(
            $Content,
            "(?i)(url\(\s*['""]?)([^'"")]*?)(?:/)?$EscapedFileName(['""]?\s*\))",
            {
                param($Match)

                $Prefix = $Match.Groups[1].Value
                $Suffix = $Match.Groups[3].Value

                return $Prefix + $CssPath + $Suffix
            }
        )
    }

    Set-Content $CssFile.FullName -Value $Content -Encoding UTF8

    Write-Host "CSS 수정: $($CssFile.Name)"
}

foreach ($File in $CssFiles) {

    $Destination = Join-Path $Root "css\$($File.Name)"

    if (-not (Test-Path $Destination)) {
        Move-Item $File.FullName $Destination
        Write-Host "CSS 이동: $($File.Name)"
    }
}

foreach ($File in $JsFiles) {

    $Destination = Join-Path $Root "js\$($File.Name)"

    if (-not (Test-Path $Destination)) {
        Move-Item $File.FullName $Destination
        Write-Host "JS 이동: $($File.Name)"
    }
}

foreach ($File in $ImageFiles) {

    $Destination = Join-Path $Root "images\$($File.Name)"

    if (-not (Test-Path $Destination)) {
        Move-Item $File.FullName $Destination
        Write-Host "이미지 이동: $($File.Name)"
    }
}

Write-Host ""
Write-Host "========================================"
Write-Host "에셋 정리 완료"
Write-Host "========================================"
Write-Host "CSS   -> css/"
Write-Host "JS    -> js/"
Write-Host "IMAGE -> images/"
Write-Host ""
