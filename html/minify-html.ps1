# index.html을 html-minifier-terser로 압축하여 minify.html로 생성합니다.
# 실행 전에 Node.js와 html-minifier-terser가 설치되어 있어야 합니다.
# html-minifier-terser가 전역 설치되어 있지 않다면 먼저 "npm install -g html-minifier-terser"를 실행합니다.
# 원본 index.html은 유지하고 압축된 HTML만 minify.html로 생성합니다.

html-minifier-terser index.html `
    --collapse-whitespace `
    --remove-comments `
    --remove-optional-tags `
    --remove-redundant-attributes `
    --remove-empty-attributes `
    --collapse-boolean-attributes `
    --remove-script-type-attributes `
    --remove-style-link-type-attributes `
    -o minify.html
