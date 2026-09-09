# 현재 폴더의 모든 이미지 파일을 org-img 폴더로 이동하는 PowerShell 스크립트

New-Item -ItemType Directory -Path ".\org-img" -Force | Out-Null

Get-ChildItem -File | Where-Object {
    $_.Extension -match '^\.(jpg|jpeg|png|gif|webp|svg|bmp|ico|avif|tif|tiff)$'
} | Move-Item -Destination ".\img-moved"
