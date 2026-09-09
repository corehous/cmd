# index.html에서 실제 사용되는 CSS만 남겨 merged.css를 정리하고 purged.css로 생성합니다.
# 실행 전에 Node.js와 PurgeCSS가 설치되어 있어야 합니다.
# PurgeCSS가 전역 설치되어 있지 않다면 먼저 "npm install -g purgecss"를 실행합니다.
# 원본 merged.css는 유지하고 정리된 CSS만 purged.css로 생성합니다.

purgecss --css merged.css --content index.html --output purged.css
