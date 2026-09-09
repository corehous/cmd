# ============================================================
# 이미지 OCR 날짜 기반 파일명 변경
#
# 기능:
#   이미지 내부의 날짜를 OCR로 인식하여
#   날짜를 기준으로 파일명을 자동 변경합니다.
#
# 처리 대상:
#   현재 실행 폴더(.)에 있는 이미지 파일
#
# 지원 확장자:
#   .jpg
#   .jpeg
#   .png
#   .webp
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
#   IMG_001.jpg
#   ↓
#   2025-05-01_001.jpg
#
# 같은 날짜의 이미지:
#   2025-05-01_001.jpg
#   2025-05-01_002.jpg
#   2025-05-01_003.jpg
#
# 기존 날짜 파일이 존재하는 경우:
#   기존 번호를 확인하여 다음 번호부터 사용합니다.
#
# OCR:
#   Tesseract OCR
#   언어: kor + eng
#
# Tesseract 설치 경로:
#   C:\Program Files\Tesseract-OCR\tesseract.exe
#
# 필요 라이브러리:
#   pip install pillow pytesseract opencv-python
#
# 실행 방법:
#   현재 폴더에서 Python으로 실행합니다.
#
# 처리 결과:
#   날짜를 찾은 이미지 → 파일명 변경
#   날짜를 찾지 못한 이미지 → 기존 파일명 유지
#
# 주의:
#   OCR 결과에 따라 날짜를 잘못 인식할 수 있습니다.
#   중요한 원본은 별도로 백업한 후 사용하는 것을 권장합니다.
# ============================================================

import os
import re
from datetime import datetime

import cv2
import pytesseract


pytesseract.pytesseract.tesseract_cmd = (
    r"C:\Program Files\Tesseract-OCR\tesseract.exe"
)

folder = "."

image_extensions = {
    ".jpg",
    ".jpeg",
    ".png",
    ".webp",
}

patterns = [
    r"(20\d{2})[./-](\d{1,2})[./-](\d{1,2})",
    r"(20\d{2})(\d{2})(\d{2})",
    r"(\d{2})[./-](\d{1,2})[./-](\d{1,2})",
    r"(20\d{2})\s*년\s*(\d{1,2})\s*월\s*(\d{1,2})\s*일",
    r"(20\d{2})\s*년\s*(\d{1,2})\s*월\s*(\d{1,2})",
]

used_names = {}

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

        try:
            datetime.strptime(
                date_str,
                "%Y-%m-%d",
            )

        except ValueError:
            continue

        return date_str

    return None


for filename in os.listdir(folder):

    ext = os.path.splitext(filename)[1].lower()

    if ext not in image_extensions:
        continue

    old_path = os.path.join(
        folder,
        filename,
    )

    try:

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

            print(f"변경 완료: {new_filename}")

        else:
            print("날짜 못찾음")

    except Exception as e:

        print(f"오류 발생: {filename}: {e}")


print()
print("=" * 60)
print("작업 완료")
print("=" * 60)
