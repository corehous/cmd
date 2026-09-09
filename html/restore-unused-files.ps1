# unused 폴더의 파일을 현재 폴더로 모두 복구합니다.

$unusedDir = Join-Path (Get-Location) "unused"

if (-not (Test-Path $unusedDir)) {
    Write-Host "unused 폴더를 찾을 수 없습니다."
    exit
}

Get-ChildItem $unusedDir -File | Move-Item -Destination (Get-Location) -Force

Write-Host "unused 폴더의 파일을 현재 폴더로 복구했습니다."
