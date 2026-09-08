# ============================================================
# Windows 사용자 PATH에서 특정 경로 제거
#
# 기능:
#   현재 사용자(User)의 PATH 환경변수에서
#   C:\app\wget 경로를 제거합니다.
#
# 처리 범위:
#   현재 사용자 PATH만 수정합니다.
#   시스템 전체(Machine) PATH는 수정하지 않습니다.
#
# 제거 대상:
#   C:\app\wget
#
# 동작:
#   1. 사용자 PATH를 가져옵니다.
#   2. 세미콜론(;) 기준으로 각각의 경로를 분리합니다.
#   3. C:\app\wget과 일치하는 경로를 제외합니다.
#   4. 나머지 경로를 다시 하나의 PATH로 합칩니다.
#   5. 수정된 PATH를 사용자 환경변수에 저장합니다.
#
# 실행 환경:
#   Windows PowerShell
#
# 실행 방법:
#   PowerShell에서 이 파일을 실행합니다.
#
# 주의:
#   C:\app\wget이 PATH에 없어도 오류 없이 실행됩니다.
#   동일한 경로가 여러 번 등록되어 있어도 모두 제거합니다.
#
# 확인 방법:
#   [Environment]::GetEnvironmentVariable("Path", "User") -split ';'
#
# 참고:
#   PATH 변경 후 새 PowerShell 창을 열어야
#   변경 내용이 새 세션에 반영됩니다.
# ============================================================

$target = "C:\app\wget"

$paths = [Environment]::GetEnvironmentVariable("Path", "User") -split ";"

$newPath = ($paths | Where-Object { $_ -and ($_ -ne $target) }) -join ";"

[Environment]::SetEnvironmentVariable("Path", $newPath, "User")
