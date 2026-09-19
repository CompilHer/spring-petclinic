from selenium import webdriver
from selenium.webdriver.chrome.options import Options

options = Options()
options.add_argument('--headless')
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')

app_url = "http://13.232.54.195"

driver = webdriver.Chrome(options=options)
try:
    driver.get(app_url)
    assert "PetClinic" in driver.title 
    print("SELENIUM TEST PASSED: Application UI loaded successfully.")
finally:
    driver.quit()