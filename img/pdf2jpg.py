@'
from pdf2image import convert_from_path
import os

for pdf in os.listdir():
    if pdf.lower().endswith(".pdf"):
        images = convert_from_path(pdf, dpi=200)
        name = os.path.splitext(pdf)[0]

        for i, image in enumerate(images, 1):
            image.save(f"{name}_{i}.jpg", "JPEG")

        print(f"완료: {pdf}")
'@ | python
