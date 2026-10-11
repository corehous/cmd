# 현재 폴더의 파일명을 랜덤 8자리로 변경
$chars = "abcdefghijklmnopqrstuvwxyz0123456789"

Get-ChildItem -File | ForEach-Object {
    do {
        $name = -join (1..8 | ForEach-Object {
            $chars[(Get-Random -Maximum $chars.Length)]
        })
        $newName = "$name$($_.Extension)"
        $target = Join-Path $_.DirectoryName $newName
    } while (Test-Path -LiteralPath $target)

    Rename-Item -LiteralPath $_.FullName -NewName $newName
}
