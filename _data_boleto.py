import fitz
import re
import sys

if len(sys.argv) < 2:
    print("Por favor, informe o caminho do arquivo PDF como argumento.")
    sys.exit(1)

# Obter o caminho do arquivo PDF
path = sys.argv[1]

# Nome do arquivo de texto que irá conter as datas de vencimento
output_file_name = r'C:\awf\datas_vencimento.txt'

# Abrir o arquivo de saída em modo de escrita, usando a codificação utf-8
with open(output_file_name, 'w', encoding='utf-8') as output_file:
    # Abrir o arquivo PDF
    with fitz.open(path) as doc:
        # Obter o número de páginas do arquivo PDF
        num_pages = doc.page_count
        
        # print(f"O arquivo PDF contém {num_pages} páginas.")

        # Percorrer as páginas do arquivo PDF
        for i in range(num_pages):
            # Obter o texto da página atual
            current_page = doc.load_page(i)
            text = current_page.get_text()
            # print(f"{text}.")

            # Procurar por padrões de data de vencimento no texto
            # pattern = r'\d{2}/\d{2}/\d{4}'
            # match = re.search(pattern, text)
            match = re.search(r'vencimento\s*(\d{2}/\d{2}/\d{4})', text, re.IGNORECASE)

            # print(f"{match}.")
            # Se uma data de vencimento for encontrada, salvar a data no arquivo de saída
            if match:
                data = match.group(1)
                output_file.write(f"{data}\n")
                #output_file.write(f"{data.replace('vencimento', '').strip()}\n")
                # output_file.write(f'Conteúdo correspondente: {text}\n\n')
