# 현재 폴더의 파일명에서 지정한 문자열을 제거합니다.

Get-ChildItem -File | ForEach-Object {

    $oldName = $_.Name
    $newName = $oldName -replace "구글검색짱토렌트_1", ""

    if ($oldName -ne $newName) {
        Rename-Item $_.FullName $newName
        Write-Host "변경: $oldName → $newName"
    }
}
