@'
import fitz
import os

# Current folder
for pdf in os.listdir():
    if pdf.lower().endswith(".pdf"):
        try:
            doc = fitz.open(pdf)
            name = os.path.splitext(pdf)[0]

            for i, page in enumerate(doc, 1):
                pix = page.get_pixmap(dpi=200)
                pix.save(f"{name}_{i}.jpg")

            print(f"완료: {pdf} ({len(doc)}페이지)")
            doc.close()

        except Exception as e:
            print(f"실패: {pdf} - {e}")

'@ | python
