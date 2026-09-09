# a-merged.css의 중복 및 불필요한 CSS를 정리하여 a-csso.css로 생성합니다.
# 실행 전에 Node.js와 CSSO가 설치되어 있어야 합니다.
# CSSO가 전역 설치되어 있지 않다면 먼저 "npm install -g csso-cli"를 실행합니다.
# 원본 a-merged.css는 유지하고 수정본만 생성합니다.

csso a-merged.css --output a-csso.css
