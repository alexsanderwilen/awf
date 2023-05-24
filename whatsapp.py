from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import time
import urllib
import sys

def send_files_to_whatsapp(numero, texto):
    navegador = webdriver.Chrome()   
    navegador.get("https://web.whatsapp.com/")    

    #while len(navegador.find_element_by_xpath('//div[@class="_1JNuk"]')) < 1:
    time.sleep(30)

    texto = urllib.parse.quote(f"{texto}")
    link = f"https://web.whatsapp.com/send?phone={numero}&text={texto}"
    navegador.get(link)
    #while len(navegador.find_element_by_xpath('//div[@class="_1JNuk"]')) < 1:
    time.sleep(10)   
    
    #mensagem = navegador.find_element_by_xpath('//*[@id="main"]/footer/div[1]/div/span[2]/div/div[2]/div[1]/div/div/p/span')
    mensagem = navegador.find_element_by_xpath('/html/body/div[1]/div/div/div[5]/div/footer/div[1]/div/span[2]/div/div[2]/div[1]/div/div/p/span')
                                                           
    mensagem.send_keys(Keys.ENTER)
    time.sleep(10)
    
if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Por favor, informe o número do telefone e a mensagem como argumentos.")
        sys.exit(1)

    numero = sys.argv[1]
    texto = ' '.join(sys.argv[2:])

    send_files_to_whatsapp(numero, texto)
