// index.html의 HTML, CSS, 인라인 JavaScript 주석을 제거하여 index-clean.html로 생성합니다.
// 실행 전에 Node.js와 @babel/parser가 설치되어 있어야 합니다.
// 원본 index.html은 유지하고 수정된 HTML만 index-clean.html로 생성합니다.

const fs = require("fs");
const parser = require("C:/Users/dksman/AppData/Roaming/npm/node_modules/@babel/parser");

const input = "index.html";
const output = "index-clean.html";

let html = fs.readFileSync(input, "utf8");

// HTML 주석 제거
html = html.replace(/<!--[\s\S]*?-->/g, "");

// <style> 내부 CSS 주석 제거
html = html.replace(
    /(<style\b[^>]*>)([\s\S]*?)(<\/style>)/gi,
    (match, open, css, close) => {
        css = css.replace(/\/\*[\s\S]*?\*\//g, "");
        return open + css + close;
    }
);

// <script> 내부 JavaScript 주석 제거
html = html.replace(
    /(<script\b[^>]*>)([\s\S]*?)(<\/script>)/gi,
    (match, open, js, close) => {

        // 외부 JS 파일은 건드리지 않음
        if (/\bsrc\s*=/i.test(open)) {
            return match;
        }

        if (!js.trim()) {
            return match;
        }

        try {
            const ast = parser.parse(js, {
                sourceType: "unambiguous",
                allowReturnOutsideFunction: true,
                attachComment: true,
                plugins: [
                    "jsx",
                    "typescript",
                    "classProperties",
                    "classPrivateProperties",
                    "classPrivateMethods",
                    "optionalChaining",
                    "nullishCoalescingOperator",
                    "dynamicImport",
                    "topLevelAwait"
                ]
            });

            const comments = ast.comments || [];

            let result = js;

            // 뒤에서부터 삭제해야 위치가 틀어지지 않음
            for (let i = comments.length - 1; i >= 0; i--) {
                const comment = comments[i];

                if (
                    typeof comment.start === "number" &&
                    typeof comment.end === "number"
                ) {
                    result =
                        result.slice(0, comment.start) +
                        result.slice(comment.end);
                }
            }

            return open + result + close;

        } catch (error) {
            console.warn("JavaScript 파싱 실패 → 해당 script는 원본 유지");
            console.warn(error.message);
            return match;
        }
    }
);

// 빈 줄 과다 정리
html = html.replace(/\n[ \t]*\n[ \t]*\n+/g, "\n\n");

// 새 파일로 저장
fs.writeFileSync(output, html, "utf8");

console.log("");
console.log("================================");
console.log("주석 제거 완료");
console.log("입력 : " + input);
console.log("출력 : " + output);
console.log("================================");
