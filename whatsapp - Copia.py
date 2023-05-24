from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import time
import urllib

def send_files_to_whatsapp(numero, texto):
    navegador = webdriver.Chrome()   
    navegador.get("https://web.whatsapp.com/")

    while len(navegador.find_elements_by_id("side")) < 1:
        time.sleep(1)

    texto = urllib.parse.quote(f"{texto}")
    link = f"https://web.whatsapp.com/send?phone={numero}&text={texto}"
    navegador.get(link)
    while len(navegador.find_elements_by_id("side")) < 1:
       time.sleep(1)
    
    navegador.find_element_by_xpath('//*[@id="main"]/footer/div[1]/dive[2]/div/div[2]').send_keys(keys.ENTER)
    time.sleep(10)
    
    
if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Por favor, informe o número do telefone e o caminho dos arquivos PDF como argumentos.")
        sys.exit(1)

    numero = sys.argv[1]
    texto = sys.argv[2:]

    send_files_to_whatsapp(numero, texto)
