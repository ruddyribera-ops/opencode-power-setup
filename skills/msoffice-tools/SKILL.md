---
name: msoffice-tools
description: Word, Excel, PowerPoint document design — advanced patterns for professional, well-structured documents
---

# MSOffice Tools — Advanced Document Design

> **Design philosophy:** A document is a designed artifact. Every margin, every spacing choice, every color is a decision. Code generates structure; style gives it meaning. Aim for "looks professionally made," not "looks like code output it."

---

## TL;DR — Document Design Checklist

- [ ] Margins set explicitly (1 inch default; adjust for print/spiral binding)
- [ ] At least 2 font sizes max (body + heading); 3 if you count caption
- [ ] Table borders: never default grid — use 1pt hairline or custom weight
- [ ] Colors: semantic or brand-consistent, never random
- [ ] Tables have header row with shading, alternating rows optional
- [ ] Page numbers in footer (center or right)
- [ ] Document has title block / header area
- [ ] Whitespace: don't crowd content; breathing room = professionalism

---

## Word Documents (`python-docx`)

### Installation

```bash
pip install python-docx
```

### Document Architecture (read first)

```
Document
├── sections[0]                    # Section properties (margins, orientation, page size)
├── paragraph                       # A paragraph is a BLOCK of text
│   ├── style.name                 # "Heading 1", "Normal", "Caption"
│   ├── alignment                  # LEFT, CENTER, RIGHT, JUSTIFY
│   ├── run                        # A run is an inline formatting chunk
│   │   ├── text
│   │   ├── bold
│   │   ├── italic
│   │   ├── font.name
│   │   └── font.size
│   └── paragraph_format
│       ├── space_before
│       ├── space_after
│       ├── left_indent
│       └── line_spacing
├── table                          # Tables come after paragraphs
│   ├── rows
│   │   ├── cells
│   │   │   ├── paragraphs
│   │   │   └── width
│   │   └── cells[i].merge(cells[j])  # Horizontal merge
│   └── rows[0].vertically_center()   # Vertical alignment
└── add_page_break()
```

---

### 1. Page Setup — Margins, Size, Orientation

```python
from docx import Document
from docx.shared import Inches, Cm, Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.section import WD_ORIENT

def create_document_with_setup(filepath):
    document = Document()

    # Section 0 is created automatically with the Document
    section = document.sections[0]
    section.page_width  = Inches(8.5)   # Letter width
    section.page_height = Inches(11)    # Letter height
    section.orientation = WD_ORIENT.PORTRAIT

    # For spiral binding: extra gutter on left
    section.left_margin   = Inches(1.0)
    section.right_margin  = Inches(1.0)
    section.top_margin    = Inches(1.0)
    section.bottom_margin = Inches(1.0)
    section.gutter        = Inches(0.5)  # Extra margin for binding

    # Or landscape
    # section.orientation = WD_ORIENT.LANDSCAPE
    # section.page_width  = Inches(11)
    # section.page_height = Inches(8.5)

    document.add_paragraph("Hello World")
    document.save(filepath)
```

---

### 2. Styles — The Document Design Foundation

```python
from docx import Document
from docx.shared import Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH

def apply_document_styles(document):
    """Define a document-wide style system."""

    # Available style names in default template:
    # 'Normal', 'Heading 1', 'Heading 2', 'Heading 3',
    # 'List Bullet', 'List Number', 'Caption', 'Quote'

    styles = document.styles

    # ── Heading 1 ──────────────────────────────────────────
    h1 = styles['Heading 1']
    h1.font.name  = 'Calibri Light'
    h1.font.size  = Pt(22)
    h1.font.bold  = True
    h1.font.color.rgb = RGBColor(0x1F, 0x49, 0x7D)  # Brand blue
    h1.paragraph_format.space_before = Pt(18)
    h1.paragraph_format.space_after  = Pt(6)

    # ── Heading 2 ──────────────────────────────────────────
    h2 = styles['Heading 2']
    h2.font.name  = 'Calibri Light'
    h2.font.size  = Pt(16)
    h2.font.bold  = True
    h2.font.color.rgb = RGBColor(0x2E, 0x74, 0xB5)
    h2.paragraph_format.space_before = Pt(14)
    h2.paragraph_format.space_after  = Pt(4)

    # ── Normal (body text) ─────────────────────────────────
    normal = styles['Normal']
    normal.font.name = 'Calibri'
    normal.font.size = Pt(11)
    normal.paragraph_format.space_after  = Pt(6)
    normal.paragraph_format.line_spacing = 1.15  # 15% more than single

    # ── Quote / Callout ────────────────────────────────────
    quote = styles['Quote']
    quote.font.name   = 'Calibri'
    quote.font.size   = Pt(11)
    quote.font.italic = True
    quote.font.color.rgb = RGBColor(0x60, 0x60, 0x60)
    quote.paragraph_format.left_indent   = Inches(0.5)
    quote.paragraph_format.space_before  = Pt(8)
    quote.paragraph_format.space_after   = Pt(8)

    return document
```

---

### 3. Paragraphs — Spacing, Indentation, Alignment

```python
from docx import Document
from docx.shared import Pt, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH

def add_styled_paragraphs(document):
    # ── Centered heading ───────────────────────────────────
    title = document.add_paragraph()
    title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = title.add_run("Annual Report 2026")
    run.bold = True
    run.font.size = Pt(28)
    run.font.name = 'Calibri Light'

    # ── Left-aligned body ───────────────────────────────────
    body = document.add_paragraph(
        "This is the body text. It uses the Normal style defined earlier."
    )

    # ── Justified text (for print documents) ────────────────
    justified = document.add_paragraph(
        "Justified text fills the line by stretching spaces between words. "
        "Common in formal documents and books."
    )
    justified.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY

    # ── Indented paragraph (for quotes/callouts) ──────────
    indented = document.add_paragraph(
        "This paragraph is indented on the left by 0.5 inches."
    )
    indented.paragraph_format.left_indent = Inches(0.5)

    # ── Bulleted list ───────────────────────────────────────
    bullet = document.add_paragraph("First bullet item", style='List Bullet')
    bullet = document.add_paragraph("Second bullet item", style='List Bullet')
    bullet = document.add_paragraph("Third bullet item", style='List Bullet')

    # ── Numbered list ───────────────────────────────────────
    num = document.add_paragraph("Step one", style='List Number')
    num = document.add_paragraph("Step two", style='List Number')
    num = document.add_paragraph("Step three", style='List Number')

    return document
```

---

### 4. Inline Formatting — Bold, Italic, Color, Highlight

```python
from docx import Document
from docx.shared import Pt, RGBColor, HighlightColor
from docx.oxml.ns import qn

def add_formatted_text(document):
    p = document.add_paragraph()

    # Plain text
    p.add_run("This is ")

    # Bold
    run = p.add_run("bold text")
    run.bold = True

    p.add_run(" and this is ")

    # Italic
    run = p.add_run("italic text")
    run.italic = True

    p.add_run(". Now ")

    # Bold + Italic combined
    run = p.add_run("bold italic")
    run.bold = True
    run.italic = True

    p.add_run(".\nColored: ")

    # Text color (font color)
    run = p.add_run("blue text")
    run.font.color.rgb = RGBColor(0x2E, 0x74, 0xB5)

    p.add_run(" | Highlighted: ")

    # Highlight (background) — use XML directly for highlight
    run = p.add_run("yellow highlight")
    run.font.highlight_color = HighlightColor.YELLOW

    p.add_run(" | Font size 14pt: ")
    run = p.add_run("larger")
    run.font.size = Pt(14)

    p.add_run(" | Subscript: ")
    run = p.add_run("H₂O")
    run.font.subscript = True

    p.add_run(" | Superscript: ")
    run = p.add_run("E=mc²")
    run.font.superscript = True

    return document
```

---

### 5. Tables — Borders, Shading, Merging, Header Row

```python
from docx import Document
from docx.shared import Pt, Inches, RGBColor, Cm
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL

def set_cell_border(cell, **kwargs):
    """Set borders on a single cell. kwargs: top, bottom, left, right."""
    tc = cell._tc
    tcPr = tc.get_or_add_tcPr()
    tcBorders = OxmlElement('w:tcBorders')
    for edge in ('top', 'left', 'bottom', 'right'):
        tag = 'w:' + edge
        element = OxmlElement(tag)
        element.set(qn('w:val'),   kwargs.get(edge, 'none'))
        element.set(qn('w:sz'),    kwargs.get('sz', '4'))
        element.set(qn('w:space'), '0')
        element.set(qn('w:color'), kwargs.get('color', 'auto'))
        tcBorders.append(element)
    tcPr.append(tcBorders)

def set_cell_shading(cell, fill_color):
    """Set cell background color."""
    tc = cell._tc
    tcPr = tc.get_or_add_tcPr()
    shading = OxmlElement('w:shd')
    shading.set(qn('w:val'),   'clear')
    shading.set(qn('w:color'), 'auto')
    shading.set(qn('w:fill'), fill_color)  # HEX: "1F497D" or "2E74B5"
    tcPr.append(shading)

def add_styled_table(document):
    # Data
    headers = ["Name", "Department", "Score", "Status"]
    rows = [
        ["María García",    "Marketing",  "94", "✅ Logrado"],
        ["Carlos Ruiz",     "Ventas",     "78", "🔄 En proceso"],
        ["Ana López",       "IT",          "85", "✅ Logrado"],
        ["Pedro Sánchez",   "RH",          "61", "⚠️ Por reforzar"],
    ]

    # Create table
    table = document.add_table(rows=len(rows) + 1, cols=len(headers))
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.style = 'Table Grid'  # Default style — will override borders below

    # ── Header row ─────────────────────────────────────────
    header_row = table.rows[0]
    for i, header in enumerate(headers):
        cell = header_row.cells[i]
        cell.text = header
        set_cell_shading(cell, "1F497D")  # Brand dark blue

        # White bold text
        para = cell.paragraphs[0]
        para.alignment = 1  # CENTER
        run = para.runs[0]
        run.bold = True
        run.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)
        run.font.size = Pt(11)

    # ── Data rows ──────────────────────────────────────────
    for row_idx, row_data in enumerate(rows):
        row = table.rows[row_idx + 1]
        # Alternate row shading
        bg = "EBF3FB" if row_idx % 2 == 0 else "FFFFFF"

        for col_idx, cell_text in enumerate(row_data):
            cell = row.cells[col_idx]
            cell.text = cell_text
            set_cell_shading(cell, bg)

            para = cell.paragraphs[0]
            run = para.runs[0]
            run.font.size = Pt(10)

            # Status column — center align
            if col_idx in (2, 3):
                para.alignment = 1  # CENTER

            # Score column — right align numbers
            if col_idx == 2:
                para.alignment = 2  # RIGHT

    # ── Column widths ──────────────────────────────────────
    widths = [Inches(1.5), Inches(1.5), Inches(0.8), Inches(1.2)]
    for row in table.rows:
        for i, cell in enumerate(row.cells):
            cell.width = widths[i]

    # ── Caption below table ─────────────────────────────────
    caption = document.add_paragraph("Tabla 1. Resultados por estudiante")
    caption.alignment = 1  # CENTER
    caption.runs[0].italic = True
    caption.runs[0].font.size = Pt(9)
    caption.paragraph_format.space_before = Pt(4)

    return document, table
```

---

### 6. Header, Footer, Page Numbers

```python
from docx import Document
from docx.shared import Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn

def add_header_and_footer(document):
    section = document.sections[0]

    # ── Header ─────────────────────────────────────────────
    header = section.header
    header_para = header.paragraphs[0]
    header_para.text = "Proyecto Mi propio Mito  |  Unidad 1 — Lenguaje  |  5to Primaria"
    header_para.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = header_para.runs[0]
    run.font.size = Pt(9)
    run.font.color.rgb  # Default color

    # ── Footer with page numbers ─────────────────────────────
    footer = section.footer
    footer_para = footer.paragraphs[0]

    # Left: "Docente: ___________"
    left_run = footer_para.add_run("Docente: ___________     ")
    left_run.font.size = Pt(9)

    # Center: page number field
    center_run = footer_para.add_run()
    center_run.add_break()  # Not a real page break — just formatting
    fldChar1 = OxmlElement('w:fldChar')
    fldChar1.set(qn('w:fldCharType'), 'begin')
    instrText = OxmlElement('w:instrText')
    instrText.text = ' PAGE '
    fldChar2 = OxmlElement('w:fldChar')
    fldChar2.set(qn('w:fldCharType'), 'separate')
    fldChar3 = OxmlElement('w:fldChar')
    fldChar3.set(qn('w:fldCharType'), 'end')
    run._r.append(fldChar1)
    center_run._r.append(instrText)
    center_run._r.append(fldChar2)
    center_run._r.append(fldChar3)
    center_run.font.size = Pt(9)
    center_run.bold = True

    # Right: "Fecha: ___________"
    right_run = footer_para.add_run("     Fecha: ___________")
    right_run.font.size = Pt(9)

    footer_para.alignment = WD_ALIGN_PARAGRAPH.CENTER

    return document
```

---

### 7. Images

```python
from docx import Document
from docx.shared import Inches, Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH

def add_image(document, image_path, width=Inches(5)):
    """Add a centered image with optional caption."""
    para = document.add_paragraph()
    para.alignment = WD_ALIGN_PARAGRAPH.CENTER

    run = para.add_run()
    run.add_picture(image_path, width=width)

    # Caption below
    caption = document.add_paragraph("Figura 1. Título de la imagen")
    caption.alignment = WD_ALIGN_PARAGRAPH.CENTER
    caption.runs[0].italic = True
    caption.runs[0].font.size = Pt(9)
    caption.paragraph_format.space_before = Pt(2)

    return document
```

---

### 8. Table of Contents (static — no auto-update in python-docx)

```python
from docx import Document
from docx.shared import Pt

def add_table_of_contents(document):
    """Add a static TOC. Note: requires manual update in Word (Ctrl+A, F9)."""
    toc_heading = document.add_paragraph("Índice")
    toc_heading.style = 'Heading 1'

    toc_items = [
        ("Dimensión Saber",    "3"),
        ("Dimensión Hacer",    "5"),
        ("Dimensión Ser/Decidir", "7"),
        ("Actividad Integradora", "9"),
        ("Rúbrica Multidimensional", "11"),
    ]

    for title, page in toc_items:
        p = document.add_paragraph()
        p.add_run(f"{title}")
        # Tab to page number
        p.add_run(f"\t{page}")
        p.paragraph_format.tab_stops.add_tab_stop(Inches(5.5), alignment=2)  # Right-align tab
        p.runs[0].font.size = Pt(11)

    return document
```

---

### 9. Complete Document Builder (all pieces together)

```python
from docx import Document
from docx.shared import Inches, Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.section import WD_ORIENT

def build_professional_document(filepath):
    document = Document()

    # 1. Page setup
    section = document.sections[0]
    section.page_width   = Inches(8.5)
    section.page_height = Inches(11)
    section.left_margin  = Inches(1.0)
    section.right_margin = Inches(1.0)
    section.top_margin   = Inches(1.0)
    section.bottom_margin = Inches(1.0)

    # 2. Styles
    document = apply_document_styles(document)

    # 3. Title block
    title = document.add_paragraph()
    title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = title.add_run("Cuestionario de Consolidación")
    run.bold = True
    run.font.size = Pt(26)
    run.font.name = 'Calibri Light'

    subtitle = document.add_paragraph()
    subtitle.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = subtitle.add_run("Unidad 1: Lenguaje  |  5to de Primaria  |  Proyecto: Mi propio Mito")
    run.font.size = Pt(12)
    run.font.color.rgb = RGBColor(0x60, 0x60, 0x60)

    document.add_paragraph()  # Spacer

    # 4. Header / Footer
    document = add_header_and_footer(document)

    # 5. Sections with headings
    h1 = document.add_paragraph("🔵 Dimensión Saber")
    h1.style = 'Heading 1'

    body = document.add_paragraph(
        "La dimensión Saber evalúa el conocimiento teórico de los conceptos "
        "trabajados en la unidad."
    )

    # 6. Table
    document, table = add_styled_table(document)

    # 7. Checkbox list (simulated with symbol)
    document.add_paragraph()
    h2 = document.add_paragraph("Actividades de verificación")
    h2.style = 'Heading 2'

    for item in ["☐ Identificar tipos de sustantivos", "☐ Reconocer elementos de la comunicación", "☐ Clasificar signos de puntuación"]:
        p = document.add_paragraph(item, style='List Bullet')

    # 8. Image placeholder
    # document = add_image(document, "path/to/image.png")

    # 9. Page break before new section
    document.add_page_break()

    h1 = document.add_paragraph("🟢 Dimensión Hacer")
    h1.style = 'Heading 1'

    document.save(filepath)
    print(f"Document saved: {filepath}")
    return filepath
```

---

## Excel Workbooks (`openpyxl`)

### Installation

```bash
pip install openpyxl
```

### Workbook Architecture (read first)

```
Workbook
├── active                        # Active sheet
├── create_sheet(name)            # Add new sheet
├── sheetnames                    # List of sheet names
├── ├── cell(row, col)            # Access cell directly
├── ├── cell(row, col).value      # Read/write cell value
├── ├── cell(row, col).number_format  # Format (date, currency, %)
├── ├── cell(row, col).fill       # Background color
├── ├── cell(row, col).font       # Font styling
├── ├── cell(row, col).border     # Border styling
├── ├── cell(row, col).alignment  # Horizontal/vertical alignment
├── ├── column_dimensions[col].width    # Column width
├── ├── row_dimensions[row].height      # Row height
├── ├── merge_cells(start:end)    # Merge range
└── └── freeze_panes              # Freeze rows/cols
```

---

### 1. Workbook and Sheet Setup

```python
from openpyxl import Workbook
from openpyxl.styles import Font, Alignment, PatternFill, Border, Side
from openpyxl.utils import get_column_letter

def create_workbook(filepath):
    wb = Workbook()

    # ── First sheet: use the default one ───────────────────
    ws = wb.active
    ws.title = "Resultados"  # Rename

    # ── Additional sheets ────────────────────────────────────
    ws2 = wb.create_sheet("Resumen")
    ws3 = wb.create_sheet("Estadísticas")

    # ── Sheet tab colors ─────────────────────────────────────
    ws.sheet_properties.tabColor  = "1F497D"   # Brand blue
    ws2.sheet_properties.tabColor = "2E74B5"

    # ── Freeze panes (keep header visible while scrolling) ──
    ws.freeze_panes = "A2"   # Freeze row 1

    wb.save(filepath)
    return wb
```

---

### 2. Cell Styling — Font, Fill, Border, Alignment

```python
from openpyxl import Workbook
from openpyxl.styles import Font, Alignment, PatternFill, Border, Side
from openpyxl.utils import get_column_letter

def style_cell(ws, row, col, value, bold=False, size=11, font_name='Calibri',
               bg_color=None, font_color="000000", h_align='left', v_align='center',
               border_style=None):
    """Apply multiple styles to a cell in one call."""
    cell = ws.cell(row=row, column=col, value=value)

    # Font
    cell.font = Font(name=font_name, size=size, bold=bold, color=font_color)

    # Alignment
    cell.alignment = Alignment(horizontal=h_align, vertical=v_align, wrap_text=True)

    # Background fill
    if bg_color:
        cell.fill = PatternFill(fill_type='solid', fgColor=bg_color)

    # Border
    if border_style:
        thin = Side(style='thin', color='AAAAAA')
        cell.border = Border(left=thin, right=thin, top=thin, bottom=thin)

    return cell
```

---

### 3. Styled Table — The Professional Spreadsheet Pattern

```python
from openpyxl import Workbook
from openpyxl.styles import Font, Alignment, PatternFill, Border, Side
from openpyxl.utils import get_column_letter

def create_styled_table(filepath):
    wb = Workbook()
    ws = wb.active
    ws.title = "Rúbrica de Evaluación"

    # ── Header row style helpers ─────────────────────────────
    header_fill    = PatternFill(fill_type='solid', fgColor='1F497D')  # Brand dark blue
    alt_fill_odd   = PatternFill(fill_type='solid', fgColor='EBF3FB')
    alt_fill_even  = PatternFill(fill_type='solid', fgColor='FFFFFF')
    header_font    = Font(name='Calibri', size=11, bold=True, color='FFFFFF')
    body_font      = Font(name='Calibri', size=10)
    thin_border    = Border(
        left=Side(style='thin', color='CCCCCC'),
        right=Side(style='thin', color='CCCCCC'),
        top=Side(style='thin', color='CCCCCC'),
        bottom=Side(style='thin', color='CCCCCC')
    )

    # ── Column headers ───────────────────────────────────────
    headers = [
        "Dimensión", "Criterio", "Por Reforzar (1)",
        "En Proceso (2)", "Logrado (3)", "Puntaje"
    ]
    col_widths = [18, 30, 25, 25, 25, 10]

    for col_idx, header in enumerate(headers, start=1):
        cell = ws.cell(row=1, column=col_idx, value=header)
        cell.font      = header_font
        cell.fill      = header_fill
        cell.alignment = Alignment(horizontal='center', vertical='center', wrap_text=True)
        cell.border    = thin_border
        ws.column_dimensions[get_column_letter(col_idx)].width = col_widths[col_idx - 1]

    ws.row_dimensions[1].height = 30  # Taller header

    # ── Data rows ────────────────────────────────────────────
    data = [
        ["SABER", "Identifica tipos de sustantivos",    "No identifica ningún tipo",         "Identifica algunos tipos",          "Identifica todos los tipos",       ""],
        ["SABER", "Reconoce elementos de comunicación", "No reconoce ningún elemento",        "Reconoce algunos elementos",       "Reconoce todos los elementos",    ""],
        ["HACER", "Crea un mini-mito original",          "No crea mito o es copiar/pegar",    "Crea mito incompleto",             "Crea mito completo y original",    ""],
        ["SER",   "Reflexiona sobre su propio proceso",  "No reflexiona",                     "Reflexión superficial",            "Reflexión profunda y honesta",     ""],
    ]

    level_fills = {
        1: PatternFill(fill_type='solid', fgColor='FFF2CC'),  # Yellow — por mejorar
        2: PatternFill(fill_type='solid', fgColor='DEEAF1'),  # Blue    — en proceso
        3: PatternFill(fill_type='solid', fgColor='E2EFDA'),   # Green   — logrado
    }

    for row_idx, row_data in enumerate(data, start=2):
        bg = alt_fill_odd if row_idx % 2 == 0 else alt_fill_even

        for col_idx, value in enumerate(row_data, start=1):
            cell = ws.cell(row=row_idx, column=col_idx, value=value)
            cell.font   = body_font
            cell.border = thin_border
            cell.alignment = Alignment(vertical='top', wrap_text=True)

            if col_idx == 1:  # Dimensión column
                cell.fill = PatternFill(fill_type='solid', fgColor='1F497D')
                cell.font = Font(name='Calibri', size=10, bold=True, color='FFFFFF')
                cell.alignment = Alignment(horizontal='center', vertical='center')
            elif col_idx in (3, 4, 5):  # Score columns
                cell.fill = level_fills[col_idx - 2]
            else:
                cell.fill = bg

    # ── Score column formula ─────────────────────────────────
    for row_idx in range(2, 2 + len(data)):
        formula = f'=IF(F{row_idx}="",0,SUMPRODUCT((C{row_idx}:E{row_idx}="Logrado")*{3,2,1}))'
        # Simpler: just mark checkboxes and sum below
        ws.cell(row=row_idx, column=6).value = ""

    wb.save(filepath)
    return wb
```

---

### 4. Conditional Formatting — Traffic Light Pattern

```python
from openpyxl import Workbook
from openpyxl.formatting.rule import ColorScaleRule, CellIsRule, FormulaRule
from openpyxl.styles import PatternFill

def add_conditional_formatting(ws):
    """Add traffic light conditional formatting to a score column."""

    # Color scale: red (low) → yellow (mid) → green (high)
    color_scale = ColorScaleRule(
        start_type='num', start_value=1, start_color='F8696B',  # Red
        mid_type='num',   mid_value=2,   mid_color='FDC868',     # Yellow
        end_type='num',   end_value=3,   end_color='63BE7B'      # Green
    )
    ws.conditional_formatting.add('F2:F100', color_scale)

    # Highlight if blank — help students not forget to fill
    blank_rule = CellIsRule(
        operator='containsErrors',
        formula=['ISBLANK(F2)'],
        fill=PatternFill(fill_type='solid', fgColor='FFCCCC')
    )
    ws.conditional_formatting.add('F2:F100', blank_rule)

    return ws
```

---

### 5. Data Entry Form — Input Validation

```python
from openpyxl import Workbook
from openpyxl.worksheet.datavalidation import DataValidation

def add_input_validation(ws):
    """Dropdown validation for Status column (D) and Dimensión column (A)."""
    # Dropdown for Dimensión
    dv_dimension = DataValidation(
        type="list",
        formula1='"SABER,HACER,SER/DECIDIR"',
        allow_blank=True
    )
    dv_dimension.error     = "Selecciona entre SABER, HACER o SER/DECIDIR"
    dv_dimension.errorTitle = "Valor inválido"
    dv_dimension.prompt    = "Haz clic para seleccionar la dimensión"
    dv_dimension.promptTitle = "Dimensión"
    ws.add_data_validation(dv_dimension)
    dv_dimension.add('A2:A100')

    # Dropdown for Status
    dv_status = DataValidation(
        type="list",
        formula1='"✅ Logrado,🔄 En proceso,⚠️ Por reforzar"',
        allow_blank=True
    )
    ws.add_data_validation(dv_status)
    dv_status.add('D2:D100')

    return ws
```

---

### 6. Charts

```python
from openpyxl import Workbook
from openpyxl.chart import BarChart, PieChart, Reference
from openpyxl.chart.label import DataLabelList

def add_chart(ws):
    # Data for chart (assume rows 1 = headers, 2+ = data)
    chart = BarChart()
    chart.type   = "col"       # Vertical bars
    chart.title  = "Resultados por Dimensión"
    chart.y_axis.title = "Puntaje promedio"
    chart.x_axis.title = "Dimensión"

    data = Reference(ws, min_col=6, min_row=1, max_row=ws.max_row)
    cats = Reference(ws, min_col=1, min_row=2, max_row=ws.max_row)
    chart.add_data(data, titles_from_data=True)
    chart.set_categories(cats)

    chart.shape = 4
    chart.width = 15   # cm
    chart.height = 10  # cm

    ws.add_chart(chart, "H2")  # Place chart at H2
    return ws
```

---

## PowerPoint Presentations (`python-pptx`)

### Installation

```bash
pip install python-pptx
```

### Presentation Architecture (read first)

```
Presentation
├── slides.add_slide(layout)      # Add a slide
├── slide.shapes                  # All shapes on a slide
│   ├── placeholder              # Pre-defined layout slot (title, body, etc.)
│   ├── textbox                  # Free-form text box
│   ├── picture                  # Image
│   ├── table                    # Table
│   └── shape                   # Basic shapes (rect, oval, line)
├── slide.shapes.title           # Title placeholder
├── slide.shapes.placeholders[i]  # Access by index
├── slide.background             # Background fill
├── slide.slide_layout           # Layout template
└── slide_width / slide_height   # Dimensions
```

---

### 1. Slide Dimensions and Layout

```python
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE

def create_presentation(filepath):
    prs = Presentation()

    # ── Slide size: widescreen (16:9) ────────────────────────
    prs.slide_width  = Inches(13.333)
    prs.slide_height = Inches(7.5)

    # ── Or standard 4:3 ─────────────────────────────────────
    # prs.slide_width  = Inches(10)
    # prs.slide_height = Inches(7.5)

    # ── Available layouts (default templates) ───────────────
    # 0 = Title Slide
    # 1 = Title and Content
    # 2 = Section Header
    # 3 = Two Content
    # 4 = Only Title
    # 5 = Blank
    # 6 = Content with Caption
    # 7 = Picture with Caption

    blank_layout = prs.slide_layouts[5]  # Blank
    title_layout  = prs.slide_layouts[0] # Title slide

    prs.save(filepath)
    return prs
```

---

### 2. Title Slide — Full Professional Treatment

```python
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE

def add_title_slide(prs):
    slide_layout = prs.slide_layouts[6]  # Title Slide layout
    slide = prs.slides.add_slide(slide_layout)

    # Background shape (full-slide rectangle — brand color)
    bg_shape = slide.shapes.add_shape(
        MSO_SHAPE.RECTANGLE,
        Inches(0), Inches(0),
        prs.slide_width, prs.slide_height
    )
    bg_shape.fill.solid()
    bg_shape.fill.fore_color.rgb = RGBColor(0x1F, 0x49, 0x7D)  # Brand blue
    bg_shape.line.fill.background()  # No border

    # Title text box
    title_box = slide.shapes.add_textbox(
        Inches(0.75), Inches(2.2),
        Inches(11.8), Inches(1.5)
    )
    tf = title_box.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "Cuestionario de Consolidación"
    p.alignment = PP_ALIGN.CENTER
    p.font.name  = 'Calibri Light'
    p.font.size  = Pt(44)
    p.font.bold  = True
    p.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

    # Subtitle
    sub_box = slide.shapes.add_textbox(
        Inches(0.75), Inches(3.8),
        Inches(11.8), Inches(1.0)
    )
    tf = sub_box.text_frame
    p = tf.paragraphs[0]
    p.text = "Unidad 1: Lenguaje  |  5to Primaria  |  Proyecto: Mi propio Mito"
    p.alignment = PP_ALIGN.CENTER
    p.font.name  = 'Calibri'
    p.font.size  = Pt(18)
    p.font.color.rgb = RGBColor(0xCC, 0xDD, 0xEE)

    # Bottom strip (accent bar)
    bar = slide.shapes.add_shape(
        MSO_SHAPE.RECTANGLE,
        Inches(0), Inches(6.8),
        prs.slide_width, Inches(0.7)
    )
    bar.fill.solid()
    bar.fill.fore_color.rgb = RGBColor(0x2E, 0x74, 0xB5)  # Lighter brand blue
    bar.line.fill.background()

    # Date / group info
    date_box = slide.shapes.add_textbox(
        Inches(0.75), Inches(6.85),
        Inches(11.8), Inches(0.5)
    )
    tf = date_box.text_frame
    p = tf.paragraphs[0]
    p.text = "Fecha: _______________     Grupo: 19 estudiantes     Proyecto: Mi propio Mito"
    p.alignment = PP_ALIGN.CENTER
    p.font.size  = Pt(12)
    p.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

    return slide
```

---

### 3. Content Slide — Title + Bullets

```python
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE

def add_content_slide(prs, title, bullets, accent_color="1F497D"):
    slide_layout = prs.slide_layouts[1]  # Title and Content
    slide = prs.slides.add_slide(slide_layout)

    # Title
    title_shape = slide.shapes.title
    title_shape.text = title
    for para in title_shape.text_frame.paragraphs:
        para.font.name  = 'Calibri Light'
        para.font.size  = Pt(36)
        para.font.bold  = True
        para.font.color.rgb = RGBColor(0x1F, 0x49, 0x7D)

    # Body — replace placeholder with content
    body_placeholder = slide.placeholders[1]
    tf = body_placeholder.text_frame
    tf.clear()

    for i, bullet in enumerate(bullets):
        if i == 0:
            p = tf.paragraphs[0]
        else:
            p = tf.add_paragraph()
        p.text = bullet
        p.level = 0
        p.font.name  = 'Calibri'
        p.font.size  = Pt(20)
        p.font.color.rgb = RGBColor(0x30, 0x30, 0x30)

    return slide
```

---

### 4. Two-Column Slide — Comparison / Table Layout

```python
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN

def add_two_column_slide(prs, title, left_title, left_items, right_title, right_items):
    slide_layout = prs.slide_layouts[2]  # Section Header
    slide = prs.slides.add_slide(slide_layout)

    # Full title
    title_shape = slide.shapes.title
    title_shape.text = title
    for para in title_shape.text_frame.paragraphs:
        para.font.name  = 'Calibri Light'
        para.font.size  = Pt(36)
        para.font.bold  = True

    # Left column header
    left_header = slide.shapes.add_textbox(
        Inches(0.7), Inches(2.2),
        Inches(5.8), Inches(0.6)
    )
    tf = left_header.text_frame
    p = tf.paragraphs[0]
    p.text = left_title
    p.font.bold = True
    p.font.size = Pt(22)
    p.font.color.rgb = RGBColor(0x1F, 0x49, 0x7D)

    # Left bullets
    left_body = slide.shapes.add_textbox(
        Inches(0.7), Inches(2.9),
        Inches(5.8), Inches(4.0)
    )
    tf = left_body.text_frame
    tf.word_wrap = True
    for i, item in enumerate(left_items):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.text = f"• {item}"
        p.font.size = Pt(16)
        p.space_after = Pt(8)

    # Right column header
    right_header = slide.shapes.add_textbox(
        Inches(6.8), Inches(2.2),
        Inches(5.8), Inches(0.6)
    )
    tf = right_header.text_frame
    p = tf.paragraphs[0]
    p.text = right_title
    p.font.bold = True
    p.font.size = Pt(22)
    p.font.color.rgb = RGBColor(0x2E, 0x74, 0xB5)

    # Right bullets
    right_body = slide.shapes.add_textbox(
        Inches(6.8), Inches(2.9),
        Inches(5.8), Inches(4.0)
    )
    tf = right_body.text_frame
    tf.word_wrap = True
    for i, item in enumerate(right_items):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.text = f"• {item}"
        p.font.size = Pt(16)
        p.space_after = Pt(8)

    return slide
```

---

### 5. Table Slide — Rubric / Scoring Grid

```python
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN

def add_table_slide(prs, title, headers, rows):
    slide_layout = prs.slide_layouts[5]  # Blank
    slide = prs.slides.add_slide(slide_layout)

    # Title
    title_box = slide.shapes.add_textbox(
        Inches(0.5), Inches(0.3),
        Inches(12.3), Inches(0.8)
    )
    tf = title_box.text_frame
    p = tf.paragraphs[0]
    p.text = title
    p.font.name  = 'Calibri Light'
    p.font.size  = Pt(28)
    p.font.bold  = True
    p.font.color.rgb = RGBColor(0x1F, 0x49, 0x7D)

    # Table
    cols = len(headers)
    tbl_left   = Inches(0.5)
    tbl_top    = Inches(1.2)
    tbl_width  = Inches(12.3)
    tbl_height = Inches(5.5)
    table = slide.shapes.add_table(len(rows) + 1, cols, tbl_left, tbl_top, tbl_width, tbl_height).table

    # Column widths
    col_widths = [Inches(2.0), Inches(2.8), Inches(2.5), Inches(2.5), Inches(2.5)]
    for i, w in enumerate(col_widths):
        table.columns[i].width = w

    # Header row
    for i, h in enumerate(headers):
        cell = table.cell(0, i)
        cell.text = h
        cell.fill.solid()
        cell.fill.fore_color.rgb = RGBColor(0x1F, 0x49, 0x7D)
        para = cell.text_frame.paragraphs[0]
        para.alignment = PP_ALIGN.CENTER
        para.font.bold = True
        para.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)
        para.font.size = Pt(12)

    # Data rows
    for row_idx, row_data in enumerate(rows):
        for col_idx, val in enumerate(row_data):
            cell = table.cell(row_idx + 1, col_idx)
            cell.text = val
            para = cell.text_frame.paragraphs[0]
            para.font.size = Pt(10)
            # Alternate shading
            if row_idx % 2 == 0:
                cell.fill.solid()
                cell.fill.fore_color.rgb = RGBColor(0xEB, 0xF3, 0xFB)

    return slide
```

---

### 6. Speaker Notes

```python
def add_speaker_notes(slide, notes_text):
    """Add speaker notes to a slide."""
    notes_slide = slide.notes_slide
    text_frame = notes_slide.notes_text_frame
    text_frame.text = notes_text
    return slide

# Example
slide = prs.slides[0]
add_speaker_notes(slide,
    "Nota para el docente: Este slide introduce la actividad integradora. "
    "Permite 5 minutos para revisión individual antes de la discusión grupal. "
    "Tener listo el Checklist de Autoevaluación en papel."
)
```

---

## Cross-Document Workflows

### Word → PDF (via LibreOffice — headless)

```bash
# Install LibreOffice (one-time)
# Windows: download from libreoffice.org
# Then convert:
soffice --headless --convert-to pdf --outdir output/ document.docx
```

### Word → PDF (via python-docx + docx2pdf)

```bash
pip install docx2pdf
python -c "from docx2pdf import convert; convert('document.docx', 'output/')"
```

### Excel → PDF (via LibreOffice)

```bash
soffice --headless --convert-to pdf --outdir output/ spreadsheet.xlsx
```

### pandoc — Swiss-army knife converter

```bash
# Markdown → Word
pandoc input.md -o output.docx

# Markdown → formatted Word with reference template
pandoc input.md --reference-doc=template.docx -o output.docx

# Word → Markdown (extract text)
pandoc input.docx -o output.md

# Markdown → PDF (via LaTeX)
pandoc input.md -o output.pdf

# Markdown → PowerPoint
pandoc input.md -o output.pptx
```

### Markdown → Styled Word via docx template

```python
import subprocess

def markdown_to_word(md_file, docx_file, ref_doc=None):
    """Convert Markdown to Word using pandoc."""
    cmd = [
        "pandoc",
        md_file,
        "-o", docx_file,
        "--reference-doc", ref_doc if ref_doc else "default",
        "--metadata", "title=Cuestionario de Consolidación"
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"pandoc error: {result.stderr}")
    return docx_file
```

---

## Design Quick Reference

### Typography Scale (for documents)

| Role | Size | Font | Weight |
|---|---|---|---|
| Display / Title | 26–36pt | Calibri Light | Bold |
| Heading 1 | 22–28pt | Calibri Light | Bold |
| Heading 2 | 16–20pt | Calibri | Bold |
| Body | 10–12pt | Calibri | Normal |
| Caption / footnote | 8–10pt | Calibri | Italic |

### Color Palette (brand-consistent)

```
Primary dark:  #1F497D  (dark brand blue)
Primary:      #2E74B5  (medium brand blue)
Accent:       #F79646  (warm orange accent)
Success:      #70AD47  (green)
Warning:      #FFC000  (yellow)
Danger:       #C00000  (red)
Text dark:    #333333
Text muted:   #666666
Light bg:     #EBF3FB  (light blue tint)
White:        #FFFFFF
```

### Spacing (document margins)

```
Formal / Print:    1.0" all sides
Spiral binding:    left +0.5" extra (gutter)
Compact (handout): 0.75" all sides
Poster / Poster:    0.5" all sides
```

---

## Common Pitfalls

| Mistake | Why it looks bad | Fix |
|---|---|---|
| Default table grid (0.5pt black) | Looks like a school assignment from 2003 | Use 1pt hairline, light gray (`AAAAAA`) |
| No header/footer on long document | Unprofessional, no page numbers | Always add header+footer |
| Random font sizes (8, 10, 12, 14, 18, 24, 36) | Visual noise, no hierarchy | Stick to 3 sizes max for body content |
| Default Word styles unchanged | "Looks like I pressed the heading button and nothing else" | Customize at least heading + normal |
| No caption below tables/images | Reader doesn't know what they're seeing | Always add "Tabla X." or "Figura X." |
| Cells with no vertical alignment set | Text sits at the bottom, looks off | `alignment.vertical = 'top'` for body cells |
| Columns too narrow (cuts text) | Wrapping breaks unexpectedly | Set explicit widths, use `wrap_text=True` |
| Mixing 3+ fonts in one document | No visual system | 1 body font + 1 display font max |
| Dark background for body text (bad contrast) | Fails WCAG AA, hard to read | Light background, dark text, ≥4.5:1 contrast |

---

## When to Use Each Format

| Format | Best for | Avoid when |
|---|---|---|
| **Word (.docx)** | Printable forms, rubrics, structured documents with tables | Need to auto-update a table of contents (needs Word to refresh field codes) |
| **Excel (.xlsx)** | Data tables, rubrics with formulas, scores, charts | Need free-form layout or images (PowerPoint is better) |
| **PowerPoint (.pptx)** | Presentations, visual guides, graphic rubrics | Need to print as a full document (PDF of slides looks like slides, not a doc) |
| **PDF** | Final delivery, teacher/formator-facing evidence | Needs editing — not editable |
| **Markdown** | Lightweight content, fast drafts, web-friendly | Complex layout — Word/PowerPoint wins |

