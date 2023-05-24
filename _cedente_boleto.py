import fitz
import re
import sys

if len(sys.argv) < 2:
    print("Por favor, informe o caminho do arquivo PDF como argumento.")
    sys.exit(1)

# Obter o caminho do arquivo PDF
path = sys.argv[1]

# Nome do arquivo de texto que irá conter o cedente e o próximo conteúdo
output_file_name = r'C:\awf\dados_cedente.txt'

# Abrir o arquivo de saída em modo de escrita, usando a codificação utf-8
with open(output_file_name, 'w', encoding='utf-8') as output_file:
    # Abrir o arquivo PDF
    with fitz.open(path) as doc:
        # Obter o número de páginas do arquivo PDF
        num_pages = doc.page_count

        # Percorrer as páginas do arquivo PDF
        for i in range(num_pages):
            # Obter o texto da página atual
            current_page = doc.load_page(i)
            text = current_page.get_text()

            # Procurar por padrões de cedente no texto
            matches = re.finditer(r'\bCedente\b', text, re.IGNORECASE)

            for match in matches:
                # Salvar a posição da primeira ocorrência encontrada
                if not 'first_match_pos' in locals():
                    first_match_pos = match.start()

                cedente = match.group().strip()
                proximo_conteudo_match = re.search(rf'{cedente}\s*(.*?)(\n|$)', text[match.end():], re.IGNORECASE|re.DOTALL)
                if proximo_conteudo_match:
                    proximo_conteudo = proximo_conteudo_match.group(1).strip()
                    output_file.write(f"{proximo_conteudo}\n\n")
                    break

                else:
                    print(f"Próximo conteúdo não encontrado após a ocorrência de '{cedente}'")
