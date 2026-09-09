# 기존 파일명의 숫자 접두사를 제거한 후 파일을 무작위로 섞어 001부터 번호를 다시 부여합니다.

Get-ChildItem -File | ForEach-Object {
    $newName = $_.Name -replace "^\d+_", ""

    if ($_.Name -ne $newName) {
        Rename-Item $_.FullName $newName
    }
}

$files = Get-ChildItem -File
$shuffled = $files | Sort-Object { Get-Random }

$i = 1

foreach ($file in $shuffled) {
    $num = "{0:D3}" -f $i
    $newName = "$num`_$($file.Name)"

    Rename-Item -LiteralPath $file.FullName -NewName $newName
    $i++
}
