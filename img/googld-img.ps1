# 현재 폴더의 JPG를 1.91:1, 1:1, 4:5 비율로 중앙 크롭하여 출력

$files = Get-ChildItem -File -Filter "*.jpg" | Sort-Object Name

$settings = @(
    @{ Width = 1200; Height = 628  }
    @{ Width = 1200; Height = 1200 }
    @{ Width = 960;  Height = 1200 }
)

foreach ($setting in $settings) {

    $width = $setting.Width
    $height = $setting.Height
    $index = 1

    foreach ($file in $files) {

        $outputName = "{0}x{1}_{2:D3}.jpg" -f $width, $height, $index
        $outputPath = Join-Path $file.DirectoryName $outputName

        magick $file.FullName `
            -resize "${width}x${height}^" `
            -gravity center `
            -extent "${width}x${height}" `
            -quality 90 `
            $outputPath

        $index++
    }
}
