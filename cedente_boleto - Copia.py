import re
import sys

def extract_next_content(path):
    # Importar a biblioteca fitz dentro da função
    import fitz
    # Lista que irá conter todos os próximos conteúdos encontrados
    next_contents = []

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
                cedente = match.group().strip()
                proximo_conteudo_match = re.search(rf'{cedente}\s*(.*?)(\n|$)', text[match.end():], re.IGNORECASE|re.DOTALL)                
                if proximo_conteudo_match:
                    matches = re.finditer(r'\bAutenticação Mecânica\b', text, re.IGNORECASE)
                        proximo_conteudo_match = re.search(rf'{Autenticação Mecânica}\s*(.*?)(\n|$)', text[match.end():], re.IGNORECASE|re.DOTALL)                                                                                              
                        proximo_conteudo = proximo_conteudo_match.group(1).strip()
                        return proximo_conteudo
                        break                    
                else:
                    print(f"Próximo conteúdo não encontrado após a ocorrência de '{cedente}'")

    # Retorna a lista de próximos conteúdos encontrados
    return proximo_conteudo


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Por favor, informe o caminho do arquivo PDF como argumento.")
        sys.exit(1)

    path = sys.argv[1]
    next_content = extract_next_content(path)
    print(f"{next_content}")
