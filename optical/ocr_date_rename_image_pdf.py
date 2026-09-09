# ============================================================
# 이미지 및 PDF OCR 날짜 기반 파일명 변경
#
# 기능:
#   이미지와 PDF 파일의 내용을 OCR로 분석하여
#   문서 내부의 날짜를 찾아 파일명을 자동 변경합니다.
#
# 처리 대상:
#   현재 실행 폴더(.)에 있는 파일
#
# 지원 확장자:
#   .jpg
#   .jpeg
#   .png
#   .webp
#   .pdf
#
# 이미지 처리:
#   OpenCV로 이미지를 읽고 흑백 변환 후
#   Tesseract OCR로 텍스트를 추출합니다.
#
# PDF 처리:
#   Poppler를 이용하여 PDF 각 페이지를 이미지로 변환한 후
#   각 페이지를 Tesseract OCR로 분석합니다.
#
# 인식 가능한 날짜 형식:
#   2025-05-01
#   2025/05/01
#   2025.05.01
#   2025-5-1
#   20250501
#   25-05-01
#   2025년05월01일
#   2025 년 5 월 1 일
#
# 파일명 변경 예:
#   원본:
#       IMG_001.jpg
#       document.pdf
#
#   변경:
#       2025-05-01_001.jpg
#       2025-05-01_002.pdf
#
# 같은 날짜의 파일:
#   2025-05-01_001.jpg
#   2025-05-01_002.pdf
#   2025-05-01_003.png
#
# OCR:
#   Tesseract OCR
#   언어: kor + eng
#
# Tesseract 설치 경로:
#   C:\Program Files\Tesseract-OCR\tesseract.exe
#
# Poppler 설치 경로:
#   C:\poppler\Library\bin
#
# 필요 라이브러리:
#   pip install pillow pytesseract opencv-python numpy pdf2image
#
# 실행 방법:
#   현재 폴더에서 Python으로 실행합니다.
#
# 처리 결과:
#   날짜를 찾은 파일 → 날짜 기반으로 파일명 변경
#   날짜를 찾지 못한 파일 → 기존 파일명 유지
#
# 주의:
#   OCR 결과에 따라 날짜를 잘못 인식할 수 있습니다.
#   중요한 원본은 별도로 백업한 후 사용하는 것을 권장합니다.
# ============================================================

import os
import re

import cv2
import numpy as np
import pytesseract

from pdf2image import convert_from_path


pytesseract.pytesseract.tesseract_cmd = (
    r"C:\Program Files\Tesseract-OCR\tesseract.exe"
)

POPPLER_PATH = r"C:\poppler\Library\bin"

folder = "."

image_extensions = [
    ".jpg",
    ".jpeg",
    ".png",
    ".webp",
]

pdf_extensions = [
    ".pdf",
]

used_names = {}

patterns = [
    r"(20\d{2})[./-](\d{1,2})[./-](\d{1,2})",
    r"(20\d{2})(\d{2})(\d{2})",
    r"(\d{2})[./-](\d{2})[./-](\d{2})",
    r"(20\d{2})\s*년\s*(\d{1,2})\s*월\s*(\d{1,2})\s*일",
    r"(20\d{2})\s*년\s*(\d{1,2})\s*월\s*(\d{1,2})",
]


for filename in os.listdir(folder):

    match = re.match(
        r"^(20\d{2}-\d{2}-\d{2})_(\d{3})\.[^.]+$",
        filename,
        re.IGNORECASE,
    )

    if not match:
        continue

    date_str = match.group(1)
    count = int(match.group(2))

    used_names[date_str] = max(
        used_names.get(date_str, 0),
        count,
    )


def extract_date(text):

    for pattern in patterns:

        match = re.search(pattern, text)

        if not match:
            continue

        yyyy = match.group(1)
        mm = match.group(2)
        dd = match.group(3)

        if len(yyyy) == 2:
            yyyy = "20" + yyyy

        mm = mm.zfill(2)
        dd = dd.zfill(2)

        date_str = f"{yyyy}-{mm}-{dd}"

        return date_str

    return None


for filename in os.listdir(folder):

    ext = os.path.splitext(filename)[1].lower()

    if ext not in image_extensions + pdf_extensions:
        continue

    old_path = os.path.join(
        folder,
        filename,
    )

    try:

        text = ""

        if ext in image_extensions:

            img = cv2.imread(old_path)

            if img is None:
                print(f"\n[오류] 이미지 읽기 실패: {filename}")
                continue

            gray = cv2.cvtColor(
                img,
                cv2.COLOR_BGR2GRAY,
            )

            text = pytesseract.image_to_string(
                gray,
                lang="kor+eng",
            )

        elif ext in pdf_extensions:

            pages = convert_from_path(
                old_path,
                poppler_path=POPPLER_PATH,
            )

            for page in pages:

                img = np.array(page)

                img = cv2.cvtColor(
                    img,
                    cv2.COLOR_RGB2BGR,
                )

                gray = cv2.cvtColor(
                    img,
                    cv2.COLOR_BGR2GRAY,
                )

                page_text = pytesseract.image_to_string(
                    gray,
                    lang="kor+eng",
                )

                text += "\n" + page_text

        print(f"\n===== {filename} =====")
        print(text)

        date_str = extract_date(text)

        if date_str:

            used_names[date_str] = (
                used_names.get(date_str, 0) + 1
            )

            count = used_names[date_str]

            new_filename = (
                f"{date_str}_{count:03d}{ext}"
            )

            new_path = os.path.join(
                folder,
                new_filename,
            )

            while os.path.exists(new_path):

                used_names[date_str] += 1

                count = used_names[date_str]

                new_filename = (
                    f"{date_str}_{count:03d}{ext}"
                )

                new_path = os.path.join(
                    folder,
                    new_filename,
                )

            os.rename(
                old_path,
                new_path,
            )

            print(
                f"변경 완료: {new_filename}"
            )

        else:

            print("날짜 못찾음")

    except Exception as e:

        print(
            f"오류 발생: {filename}: {e}"
        )
