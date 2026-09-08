# ============================================================
# Windows 사용자 PATH에 프로그램 경로 추가
#
# 기능:
#   현재 사용자(User)의 PATH 환경변수에
#   C:\app\wget 경로를 추가합니다.
#
# 처리 범위:
#   현재 사용자 PATH만 수정합니다.
#   시스템 전체(Machine) PATH는 수정하지 않습니다.
#
# 추가되는 경로:
#   C:\app\wget
#
# 실행 환경:
#   Windows PowerShell
#
# 실행 방법:
#   PowerShell에서 이 파일을 실행합니다.
#
# 주의:
#   이미 C:\app\wget이 PATH에 등록되어 있어도
#   다시 실행하면 동일한 경로가 중복으로 추가될 수 있습니다.
#
# 확인 방법:
#   [Environment]::GetEnvironmentVariable("Path", "User") -split ';'
# ============================================================

[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\app\wget",
    "User"
)
