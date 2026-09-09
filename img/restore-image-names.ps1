# blabla.jpg@v=blabla 와 같은 폴더 내 여러 파일 같은..
# 현재 폴더의 이미지 파일에서 깨진 파일명 뒤의 불필요한 문자열을 제거하고
# 원래 이미지 파일명으로 복원하는 PowerShell 스크립트
# 1. 현재 폴더의 파일을 확인한다.
# 2. 이미지 파일만 추려낸다.
# 3. blabla.jpg@v=blabla와 같은 파일명에서 정상적인 확장자까지만 추출한다.
# 4. 확장자 앞의 원래 파일명을 유지한다.
# 5. 같은 이름의 파일이 이미 존재하면 001, 002, 003 순서로 번호를 붙인다.
# 6. 최종적으로 원래 이름 + 올바른 확장자로 변경한다.


# 이미지 확장자 목록
$imageExtensions = @(
    ".jpg",
    ".jpeg",
    ".jpe",
    ".png",
    ".gif",
    ".webp",
    ".bmp",
    ".tiff",
    ".tif",
    ".heic",
    ".heif",
    ".avif",
    ".jfif",
    ".pjpeg",
    ".pjp",
    ".ico",
    ".svg"
)


Get-ChildItem -File | ForEach-Object {

    # 파일명에서 정상적인 이미지 확장자까지 추출
    if ($_.Name -match '^(.+?)(\.(jpg|jpeg|jpe|png|gif|webp|bmp|tiff|tif|heic|heif|avif|jfif|pjpeg|pjp|ico|svg))') {

        $baseName = $matches[1]
        $extension = $matches[2].ToLower()

    }
    else {
        return
    }


    # 원래 파일명 생성
    $newName = "$baseName$extension"


    # 같은 이름의 파일이 존재하면 001부터 번호 추가
    if (Test-Path -LiteralPath (Join-Path $_.DirectoryName $newName)) {

        $number = 1

        do {
            $suffix = "{0:D3}" -f $number
            $newName = "$baseName$suffix$extension"
            $number++
        }
        while (Test-Path -LiteralPath (Join-Path $_.DirectoryName $newName))
    }


    # 이미 원하는 이름이면 변경하지 않음
    if ($_.Name -eq $newName) {
        return
    }


    # 파일명 변경
    Rename-Item -LiteralPath $_.FullName -NewName $newName


    Write-Host "변경: $($_.Name) → $newName"
}
