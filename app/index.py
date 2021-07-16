# import libraries
from urllib.request import urlopen
from bs4 import BeautifulSoup
import re
from selenium import webdriver

def getZH():
    # specify the url
    quote_page = 'https://www.zerohedge.com'

    # query the website and return the html to the variable ‘page’
    page = urlopen(quote_page)
    soup = BeautifulSoup(page, 'html.parser')
    zhedgeArticles = []

    for div in soup.findAll('div', {'class': re.compile('Article_stickyContainer')}):
        zhedgeArticles.append(div.findChild('div').findChild('h2').findChild('a')['href'])
    for div in soup.findAll('div', {'class': re.compile('Article_nonStickyContainer')}):
        zhedgeArticles.append('https://www.zerohedge.com' + div.findChild('div').findChild('h2').findChild('a')['href'])
    print(zhedgeArticles)

def getWSJ():
    browser = webdriver.Chrome() 
    test = browser.get('https://www.wsj.com')
    print('j',test)
    ## Login Credentials
    login = browser.find_element_by_link_text("Log In").click()
    loginID = browser.find_element_by_id("username").send_keys('')             # Input username
    loginPass = browser.find_element_by_id("password").send_keys('')     # Input password
    loginReady = browser.find_element_by_class_name("login_submit")
    loginReady.submit()   
    search_box = browser.find_element_by_id("globalHatSearchInput")
    print(search_box)
getWSJ()