import os
import shutil
import subprocess
import pypdf

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

def build_pdf():
    print("=" * 60)
    print("Building Publication PDF with Front & Back Covers...")
    print("=" * 60)

    quarto_bin = shutil.which("quarto") or r"C:\Program Files\Quarto\bin\quarto.exe"
    typst_front = os.path.join(ROOT, "typst", "front-cover.typ")
    typst_back = os.path.join(ROOT, "typst", "back-cover.typ")
    front_pdf = os.path.join(ROOT, "downloads", "front-cover.pdf")
    back_pdf = os.path.join(ROOT, "downloads", "back-cover.pdf")
    book_pdf = os.path.join(ROOT, "downloads", "FROM-DATA-TO-THESIS.pdf")
    output_pdf = os.path.join(ROOT, "downloads", "From-Data-to-Thesis.pdf")

    # 1. Compile 1-page front and back covers from typst
    print("1. Compiling front and back covers...")
    subprocess.run(
        [quarto_bin, "typst", "compile", typst_front, front_pdf, "--root", "."],
        cwd=ROOT,
        check=True
    )
    subprocess.run(
        [quarto_bin, "typst", "compile", typst_back, back_pdf, "--root", "."],
        cwd=ROOT,
        check=True
    )

    # 2. Check if book body PDF exists, if not, render via Quarto
    if not os.path.exists(book_pdf):
        print("2. Rendering book body via Quarto Typst...")
        subprocess.run(
            [quarto_bin, "render", "content/book", "--to", "typst"],
            cwd=ROOT,
            check=True
        )

    # 3. Merge front cover + book body + back cover
    print("3. Merging front cover, book body, and back cover...")
    writer = pypdf.PdfWriter()

    front_reader = pypdf.PdfReader(front_pdf)
    for p in front_reader.pages:
        writer.add_page(p)

    body_reader = pypdf.PdfReader(book_pdf)
    total_body_pages = len(body_reader.pages)
    start_idx = 1 if (total_body_pages > 1 and not body_reader.pages[0].extract_text().strip()) else 0
    end_idx = (total_body_pages - 1) if (total_body_pages > 1 and not body_reader.pages[-1].extract_text().strip()) else total_body_pages

    for i in range(start_idx, end_idx):
        writer.add_page(body_reader.pages[i])

    back_reader = pypdf.PdfReader(back_pdf)
    for p in back_reader.pages:
        writer.add_page(p)

    temp_pdf = os.path.join(ROOT, "downloads", "_temp_merged.pdf")
    with open(temp_pdf, "wb") as f:
        writer.write(f)

    shutil.move(temp_pdf, output_pdf)

    # Copy to _site/downloads if _site exists
    site_dl = os.path.join(ROOT, "_site", "downloads")
    if os.path.exists(site_dl):
        site_pdf = os.path.join(site_dl, "From-Data-to-Thesis.pdf")
        shutil.copy2(output_pdf, site_pdf)

    total_pages = len(writer.pages)
    file_size_mb = os.path.getsize(output_pdf) / (1024 * 1024)
    print(f"SUCCESS: Generated {output_pdf}")
    print(f"Total Pages: {total_pages}")
    print(f"File Size: {file_size_mb:.2f} MB")
    print("=" * 60)

if __name__ == "__main__":
    build_pdf()
