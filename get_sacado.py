import re
import sys
import fitz

def get_sacado(path):
    # Importar a biblioteca fitz dentro da função
    import fitz
    # Lista que irá conter todos os próximos conteúdos encontrados
    next_contents = []
    proximo_conteudo = None

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
            matches = re.search(r'\bSacado\s*:\s*', text, re.IGNORECASE)

            if not matches:
                matches = re.search(r'\bSacado\b', text, re.IGNORECASE)

            if matches:
                sacado = matches.group().strip()

                # Buscar pelo próximo conteúdo em qualquer linha
                proximo_conteudo_match = re.search(rf'{sacado}\n\s*(.*?)(?=\n\S)', text, re.IGNORECASE|re.DOTALL)
                if proximo_conteudo_match:
                    proximo_conteudo = proximo_conteudo_match.group(1).strip()
                    proximo_conteudo = re.sub(r'\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}\-', '', proximo_conteudo).strip()
                    proximo_conteudo = re.sub(r'\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}', '', proximo_conteudo).strip()
                    return proximo_conteudo
                else:
                    print(f"Próximo conteúdo não encontrado após a ocorrência de '{sacado}'")
              
    # Retorna a lista de próximos conteúdos encontrados
    return proximo_conteudo
    
    
if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Por favor, informe o caminho do arquivo PDF como argumento.")
        sys.exit(1)

    path = sys.argv[1]
    next_content = get_sacado(path)
    print(f"{next_content}")    