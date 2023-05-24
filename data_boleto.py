import fitz
import re
import sys

def extract_vencimento_from_pdf(path):
    def extract_vencimento(text):
        match = re.search(r'vencimento\s*(\d{2}/\d{2}/\d{4})', text, re.IGNORECASE)
        if match:
            return match.group(1)
        return None

    with fitz.open(path) as doc:
        num_pages = doc.page_count
        for i in range(num_pages):
            current_page = doc.load_page(i)
            text = current_page.get_text()
            vencimento = extract_vencimento(text)
            if vencimento:
                return vencimento

    return None

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Por favor, informe o caminho do arquivo PDF como argumento.")
        sys.exit(1)

    path = sys.argv[1]
    vencimento = extract_vencimento_from_pdf(path)
    if vencimento:
        print(f"{vencimento}")
    else:
        print("Vencimento não encontrado no arquivo PDF.")        
