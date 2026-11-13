@'
import pymupdf
import os

# Current folder
folder = os.getcwd()

# Find PDF files in current folder only
files = [
    f for f in os.listdir(folder)
    if f.lower().endswith(".pdf")
    and os.path.isfile(f)
]

# Check PDF files
if not files:
    print("PDF 파일이 없습니다.")

# Convert PDF to JPG
for pdf in files:
    try:
        # Open PDF
        doc = pymupdf.open(pdf)

        # Output filename
        name = os.path.splitext(pdf)[0]

        # Convert each page
        for i, page in enumerate(doc, 1):
            pix = page.get_pixmap(dpi=200)
            output = f"{name}_{i}.jpg"
            pix.save(output)

        print(f"완료: {pdf} ({len(doc)}페이지)")

        # Close PDF
        doc.close()

    except Exception as e:
        print(f"실패: {pdf}")
        print(f"오류: {e}")

print("\n모든 작업이 완료되었습니다.")

'@ | python
