import os
pdf_files = [f for f in os.listdir() if f.lower().endswith(".pdf")]
for pdf_file in pdf_files:
    os.remove(pdf_file)
    print(f"Deleted: {pdf_file}")
print("All PDF files deleted")
