# ============================================================
# PDF → JPG 변환 프로그램
#
# 기능:
#   현재 폴더의 모든 PDF를 페이지별 JPG로 변환합니다.
#
# 처리 범위:
#   현재 폴더만 처리합니다.
#   하위 폴더는 검색하거나 처리하지 않습니다.
#
# 대상 파일:
#   .pdf
#
# 출력 파일:
#   원본이름_001.jpg
#   원본이름_002.jpg
#   ...
#
# 필요한 패키지:
#   pdf2image
#
# 설치:
#   pip install pdf2image
#
# 필요한 외부 프로그램:
#   Poppler
#
# 실행:
#   python pdf-to-jpg.py
#
# 주의:
#   현재 폴더에 있는 모든 PDF가 자동으로 처리됩니다.
# ============================================================

from pdf2image import convert_from_path
import os

pdf_files = [f for f in os.listdir() if f.lower().endswith(".pdf")]

for pdf_file in pdf_files:
    pdf_name = os.path.splitext(pdf_file)[0]

    images = convert_from_path(pdf_file, dpi=200)

    for i, image in enumerate(images, start=1):
        page_number = f"{i:03}"
        image_filename = f"{pdf_name}_{page_number}.jpg"
        image.save(image_filename, "JPEG")

    print(f"완료: {pdf_file}")
