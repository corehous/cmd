# 현재 폴더와 모든 하위 폴더의 CSS 파일에서 CSS 주석(/* ... */)을 제거합니다.
# 원본 CSS 파일을 직접 수정합니다.
# 하위 폴더의 CSS 파일도 모두 처리합니다.

$files = Get-ChildItem -Path "." -Filter "*.css" -File -Recurse

foreach ($file in $files) {

    $css = [System.IO.File]::ReadAllText(
        $file.FullName,
        [System.Text.Encoding]::UTF8
    )

    # CSS 주석 제거
    $css = [regex]::Replace(
        $css,
        '/\*[\s\S]*?\*/',
        ''
    )

    [System.IO.File]::WriteAllText(
        $file.FullName,
        $css,
        [System.Text.UTF8Encoding]::new($false)
    )

    Write-Host "주석 제거: $($file.FullName)"
}
