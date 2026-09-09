# 파일명을 소문자로 변환하고 한글, 영문, 숫자, -, _만 남기며 공백을 -로 변환합니다.

Get-ChildItem -File | ForEach-Object {

    $oldName = $_.Name
    $base = $_.BaseName
    $ext = $_.Extension

    $new = $base.ToLower()
    $new = $new -replace '\s+', '-'
    $new = $new -replace '[^a-z0-9가-힣_-]', ''
    $new = $new -replace '[-_]{2,}', '-'
    $new = $new.Trim('-')

    $newName = $new + $ext

    if ($oldName -ne $newName) {
        Rename-Item $_.FullName $newName
        Write-Host "변경: $oldName → $newName"
    }
}
