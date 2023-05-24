import fitz
import re
import sys

def extract_content_from_pdf(path):
    # Nome do arquivo de texto que irá conter o sacado e o próximo conteúdo
    output = ""

    # Abrir o arquivo PDF
    with fitz.open(path) as doc:
        # Obter o número de páginas do arquivo PDF
        num_pages = doc.page_count

        # Variável para controlar se já encontramos o sacado
        sacado_encontrado = False

        # Percorrer as páginas do arquivo PDF
        for i in range(num_pages):
            # Obter o texto da página atual
            current_page = doc.load_page(i)
            text = current_page.get_text()
            #print(f"O texto completo é: {text}")

            # Verificar se já encontramos o sacado
            if not sacado_encontrado:
                # Procurar pelo padrão de sacado no texto
                # match = re.search(r'\bSacado\b', text, re.IGNORECASE)
                # match = re.search(r'\bSacado:\b', text, re.IGNORECASE)
                match = re.search(r'\bSacado\s*:\s*', text, re.IGNORECASE)

                if not match:
                    match = re.search(r'\bSacado\b', text, re.IGNORECASE)

                if match:
                    sacado_encontrado = True
                    sacado = match.group().strip()

                    # Buscar pelo próximo conteúdo em qualquer linha
                    proximo_conteudo_match = re.search(rf'{sacado}\n\s*(.*?)(?=\n\S)', text, re.IGNORECASE|re.DOTALL)
                    if proximo_conteudo_match:                        
                        proximo_conteudo = proximo_conteudo_match.group(1).strip()
                        proximo_conteudo = re.sub(r'\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}\-', '', proximo_conteudo).strip()
                        proximo_conteudo = re.sub(r'\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}', '', proximo_conteudo).strip()
                        return proximo_conteudo                        
                    else:                        
                        print(f"Próximo conteúdo não encontrado após a ocorrência de '{sacado}'")
            else:
                break

        # Verificar se encontramos o sacado
        if not sacado_encontrado:
            print("Não foi encontrada nenhuma ocorrência de 'Sacado' no arquivo PDF.")