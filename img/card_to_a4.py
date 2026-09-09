# 카드 앞·뒤 이미지 2장을 자동으로 추출하여 A4 세로 이미지로 결합하는 프로그램
#
# 작동 방식
# 1. 현재 폴더에서 JPG/JPEG 이미지 2개를 찾는다.
# 2. 파일명 순서대로 앞면 → 뒷면으로 처리한다.
# 3. 각 이미지에서 카드 영역을 자동으로 인식한다.
# 4. 카드 영역만 추출한다.
# 5. 앞면과 뒷면의 너비를 동일하게 맞춘다.
# 6. 앞면과 뒷면을 위·아래로 결합한다.
# 7. A4 세로 비율의 흰색 캔버스 중앙에 배치한다.
# 8. 최종 결과를 merged_A4.jpg로 저장한다.
# 9. 중간 작업 파일은 생성하지 않는다.


import cv2
import glob
from PIL import Image


# ==============================
# 설정
# ==============================

A4_WIDTH = 1654
A4_HEIGHT = 2339

CARD_GAP = 30

OUTPUT = "merged_A4.jpg"


# ==============================
# JPG 이미지 2개 찾기
# ==============================

files = sorted(
    glob.glob("*.jpg") +
    glob.glob("*.jpeg")
)

if len(files) != 2:
    print(f"JPG 이미지가 정확히 2개 필요합니다. 현재 {len(files)}개입니다.")
    raise SystemExit


# ==============================
# 카드 영역 자동 인식 및 추출
# ==============================

def find_card(file):

    image = cv2.imread(file, cv2.IMREAD_GRAYSCALE)

    if image is None:
        print("이미지를 읽을 수 없습니다:", file)
        raise SystemExit

    edges = cv2.Canny(image, 50, 150)

    contours, _ = cv2.findContours(
        edges,
        cv2.RETR_EXTERNAL,
        cv2.CHAIN_APPROX_SIMPLE
    )

    candidates = []

    for contour in contours:

        x, y, w, h = cv2.boundingRect(contour)

        if w > 500 and h > 300:
            candidates.append((x, y, w, h))

    if not candidates:
        print("카드 영역을 찾지 못했습니다:", file)
        raise SystemExit

    # 가장 큰 영역을 카드 영역으로 선택
    x, y, w, h = max(
        candidates,
        key=lambda r: r[2] * r[3]
    )

    # 원본 컬러 이미지에서 카드 영역 추출
    img = Image.open(file).convert("RGB")

    card = img.crop(
        (x, y, x + w, y + h)
    )

    print(f"{file} → 카드 영역 {w} × {h}")

    return card


# ==============================
# 앞면 / 뒷면 카드 추출
# ==============================

front = find_card(files[0])
back = find_card(files[1])


# ==============================
# 앞면 / 뒷면 너비 통일
# ==============================

width = min(
    front.width,
    back.width
)

front = front.resize(
    (
        width,
        int(front.height * width / front.width)
    )
)

back = back.resize(
    (
        width,
        int(back.height * width / back.width)
    )
)


# ==============================
# 앞면 + 뒷면 결합
# ==============================

merged_width = width

merged_height = (
    front.height
    + CARD_GAP
    + back.height
)

merged = Image.new(
    "RGB",
    (
        merged_width,
        merged_height
    ),
    "white"
)

# 앞면 배치
merged.paste(
    front,
    (0, 0)
)

# 뒷면 배치
merged.paste(
    back,
    (
        0,
        front.height + CARD_GAP
    )
)


# ==============================
# A4 캔버스 생성
# ==============================

result = Image.new(
    "RGB",
    (
        A4_WIDTH,
        A4_HEIGHT
    ),
    "white"
)


# ==============================
# A4 중앙 배치
# ==============================

x = (
    A4_WIDTH - merged.width
) // 2

y = (
    A4_HEIGHT - merged.height
) // 2

result.paste(
    merged,
    (x, y)
)


# ==============================
# 최종 결과 저장
# ==============================

result.save(
    OUTPUT,
    quality=95
)


print()
print("================================")
print("완료!")
print("================================")
print("파일:", OUTPUT)
print("크기:", result.size)
