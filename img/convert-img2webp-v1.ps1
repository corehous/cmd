# Output folder
$outputDir = "webp"

# Create output folder
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

# Convert PNG, JPG, JPEG to WEBP
Get-ChildItem -File | Where-Object {
    $_.Extension -match '^\.(png|jpe?g)$'
} | ForEach-Object {

    $size = magick identify -format "%wx%h" "$($_.FullName)"
    $random = -join (97..122 | Get-Random -Count 3 | ForEach-Object {[char]$_})
    $newName = "$($size)$random.webp"
    $outputPath = Join-Path $outputDir $newName

    magick "$($_.FullName)" -strip -quality 85 "$outputPath"

}
