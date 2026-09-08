# ============================================================
# 현재 PowerShell 세션의 PATH 새로고침
#
# 기능:
#   Windows의 Machine PATH와 User PATH를 다시 읽어
#   현재 PowerShell 세션의 $env:Path에 적용합니다.
#
# 처리 범위:
#   파일이나 폴더를 검색하지 않습니다.
#   PATH 환경변수만 다시 불러옵니다.
#
# PATH 구성:
#   1. Machine PATH
#   2. User PATH
#   두 값을 합쳐 현재 세션의 PATH로 설정합니다.
#
# 주요 용도:
#   새로운 프로그램 경로를 PATH에 추가하거나 제거한 후
#   PowerShell 창을 새로 열지 않고 현재 세션에서
#   변경된 PATH를 사용할 때 사용할 수 있습니다.
#
# 실행 환경:
#   Windows PowerShell
#
# 실행 방법:
#   PowerShell에서 이 파일을 실행합니다.
#
# 확인 방법:
#   $env:Path -split ';'
#
# 주의:
#   이 코드는 Windows의 영구적인 PATH 값을 변경하지 않습니다.
#   현재 실행 중인 PowerShell 세션의 $env:Path만 변경합니다.
# ============================================================

$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
[Environment]::GetEnvironmentVariable("Path", "User")
