# 파일명 앞의 숫자_ 접두사를 제거합니다.

Get-ChildItem -File | ForEach-Object {
    $newName = $_.Name -replace "^\d+_", ""

    if ($_.Name -ne $newName) {
        Rename-Item $_.FullName $newName
    }
}
