import sys
from selenium import webdriver
import time

def send_files_to_whatsapp(numero, arquivos_pdf):
    # Define o caminho para o driver do Selenium
    DRIVER_PATH = 'C:\awf\chromedriver\chromedriver.exe'

    # Inicializa o driver do Selenium
    driver = webdriver.Chrome(executable_path=DRIVER_PATH)

    # Acessa o WhatsApp Web
    driver.get('https://web.whatsapp.com/')
    time.sleep(10)

    # Verifica se o WhatsApp Web já está aberto
    try:
        # Procura pelo elemento da barra de pesquisa
        driver.find_element_by_xpath('//div[@class="_1JNuk"]')
    except:
        # Se o elemento não estiver presente, solicita que o usuário escaneie o código QR
        input('Por favor, escaneie o código QR do WhatsApp Web e pressione ENTER')
        time.sleep(10)

    # Procura pelo contato na lista de conversas
    contatos = driver.find_element_by_xpath('//div[@class="_2_1wd copyable-text selectable-text"][@contenteditable="true"][@data-tab="3"]')
    contatos.send_keys(numero)
    time.sleep(2)

    # Abre a conversa com o contato
    driver.find_element_by_xpath('//span[@class="_1wjpf"]').click()
    time.sleep(2)

    # Clica no botão "Anexar" para enviar o arquivo
    anexar_btn = driver.find_element_by_xpath('<span[@data-testid="clip"]')
    anexar_btn.click()
    time.sleep(2)

    # Seleciona a opção "Documento" no menu de anexos
    doc_btn = driver.find_element_by_xpath('//input[@accept=".pdf,.doc,.docx,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document"]')
    doc_btn.send_keys(arquivos_pdf)
    time.sleep(2)

    # Clica no botão "Enviar"
    enviar_btn = driver.find_element_by_xpath('<span[@data-testid="send"]')
    enviar_btn.click()
    time.sleep(2)

    # Fecha o navegador
    driver.quit()

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Por favor, informe o número do telefone e o caminho dos arquivos PDF como argumentos.")
        sys.exit(1)

    numero = sys.argv[1]
    arquivos_pdf = sys.argv[2:]

    send_files_to_whatsapp(numero, arquivos_pdf)
