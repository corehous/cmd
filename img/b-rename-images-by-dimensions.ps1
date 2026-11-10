# Output folder
$outputDir = "renamed"

# Create output folder
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

# Generate 3 random lowercase letters
function Get-RandomLetters {
    $chars = "abcdefghijklmnopqrstuvwxyz"
    return -join (1..3 | ForEach-Object {
        $chars[(Get-Random -Minimum 0 -Maximum 26)]
    })
}

# Process image files in current folder only
Get-ChildItem -File | Where-Object {
    $_.Extension -match '(?i)^\.(jpg|jpeg|png|webp|gif|bmp|tiff|avif)$'
} | ForEach-Object {

    $file = $_

    # Get actual image dimensions
    $info = (magick identify -format "%w %h" "$($file.FullName)").Trim()

    $w, $h = $info -split "\s+"

    # Generate unique filename
    do {
        $rand = Get-RandomLetters

        $fileName = "${w}x${h}${rand}$($file.Extension.ToLower())"

        $outputPath = Join-Path $outputDir $fileName
    }
    while (Test-Path -LiteralPath $outputPath)

    # Copy original file without modification
    Copy-Item -LiteralPath $file.FullName -Destination $outputPath

    Write-Host "복사: $($file.Name) → $fileName"
}

Write-Host "`n완료! 결과는 '$outputDir' 폴더에 저장되었습니다." -ForegroundColor Green
