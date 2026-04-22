---
name: ocr-tools
---

## OCR Tools (Optical Character Recognition)

### Tesseract OCR (Free, Offline)

Tesseract is a powerful open-source OCR engine. It's excellent for extracting text from images, scanned documents, and screenshots.

**1. Installation (WSL2/Linux)**

```bash
sudo apt-get update
sudo apt-get install tesseract-ocr
sudo apt-get install tesseract-ocr-eng # For English language pack
# Install other language packs as needed, e.g., tesseract-ocr-spa for Spanish
```

**2. Python Snippet (using `pytesseract`)**

First, install the Python wrapper:

```bash
pip install pytesseract Pillow
```

Then, use this Python code:

```python
import pytesseract
from PIL import Image

# Point to your tesseract executable if it's not in your PATH
# pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe' # Windows example

image_path = 'path/to/your/image.png'
text = pytesseract.image_to_string(Image.open(image_path))
print(text)
```

**3. Bash One-Liner**

```bash
tesseract path/to/your/image.png output_text_file
cat output_text_file.txt
```

### EasyOCR (Alternative)

EasyOCR is a more modern, deep-learning-based OCR tool that supports many languages out-of-the-box and can be more accurate for certain types of text.

**1. Installation**

```bash
pip install easyocr
```

**2. Python Snippet**

```python
import easyocr

reader = easyocr.Reader(['en']) # Specify languages, e.g., ['en', 'es']
result = reader.readtext('path/to/your/image.png')

for (bbox, text, prob) in result:
    print(f'Text: {text}, Confidence: {prob:.2f}')
```
