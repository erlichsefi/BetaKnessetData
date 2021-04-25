#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os,time
import requests
import numpy as np
import pandas as pd
import lxml.html as LH
from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
from urllib.parse import urlparse,urlunparse,urlencode
from selenium.webdriver.common.by import By
from selenium.common.exceptions import NoSuchElementException

base_url = "https://www.knesset.gov.il/vote/heb/Vote_Res_Map.asp"
search_url = "https://www.knesset.gov.il/vote/heb/vote_search.asp"


def scrap_table(driver, title):
    names = list()
    parties = list()
    try:
        against_table = driver.find_element_by_xpath(f"//*[contains(text(),'{title}')]")
        against_table = against_table.find_elements(By.XPATH, "./../..")[0]
        
        for tr in against_table.find_elements(By.TAG_NAME,"tr")[2:-1]:
                names.append(tr.find_elements(By.TAG_NAME,"td")[1].text)
                parties.append(tr.find_elements(By.TAG_NAME,"td")[2].text)
    except NoSuchElementException:
        pass

    return names,parties

def is_empty(x):
    return len(x) == 3 and x.count(" ") == 2 and x.count('"') == 1

latest_rule_id = 33461
options = webdriver.ChromeOptions()
options.add_experimental_option("excludeSwitches", ["enable-automation"])
options.add_experimental_option('useAutomationExtension', False)
options.add_argument("disable-blink-features=AutomationControlled")

driver = webdriver.Chrome(ChromeDriverManager().install(),options=options)
url = urlparse(base_url)
for rule_id in range(latest_rule_id, 0, -1):
    
    query_string = urlencode({"vote_id_t": str(rule_id)})   
    url_parse = url._replace(query=query_string)
    new_url = urlunparse(url_parse)
    driver.get(new_url)
    
    time.sleep(5)
    try:
        in_favor_name, in_favor_party = scrap_table(driver, 'שהצביעו בעד')
        against_name, against_party = scrap_table(driver, 'שהצביעו נגד')
        avoid_name, avoid_party = scrap_table(driver, 'שהצביעו שנמנעו')
        didnot_vote_name, didnot_vote_party = scrap_table(driver, 'שלא הצביע') 

        committee_num = driver.find_element_by_xpath(f"//*[contains(text(),'מספר הצבעה')]/./../td[2]").text

        meeting_num = driver.find_element_by_xpath(f"//*[contains(text(),'מספר ישיבה')]/./../td[2]").text

        date = driver.find_element_by_xpath(f"//*[contains(text(),'תאריך')]/./../td[2]").text

        rule = driver.find_element_by_xpath(f"//*[contains(text(),'שם החוק')]/./../td[2]").text

        head_name = driver.find_element_by_xpath(f"//*[contains(text(),'יושב ראש')]/./../td[2]").text

        in_favor_df = pd.DataFrame(list(zip(in_favor_name, in_favor_party))[1:], columns=['Name', 'Party'])
        in_favor_df['Vote'] = 'בעד'

        against_df = pd.DataFrame(list(zip(against_name, against_party))[1:], columns=['Name', 'Party'])
        against_df['Vote'] = 'נגד'

        avoid_df = pd.DataFrame(list(zip(avoid_name, avoid_party))[1:], columns=['Name', 'Party'], )
        avoid_df['Vote'] = 'נמנע'

        didnot_vote_df = pd.DataFrame(list(zip(didnot_vote_name, didnot_vote_party))[1:], columns=['Name', 'Party'], )
        didnot_vote_df['Vote'] = 'לא הצביע'

        dataframes = [in_favor_df, against_df, avoid_df, didnot_vote_df]

        for df in dataframes:
            df["Party"] = df["Party"].apply( lambda x: np.nan if is_empty(x) else x)
            df.fillna(method='ffill', inplace=True)
            df['Rule Name'] = rule
            df['Meeting Date'] = date
            df['Committee Leader Name'] = head_name
            df['Vote Number'] = committee_num
            df['Meeting Number'] = meeting_num
            df['Id'] = 'https://www.knesset.gov.il/vote/heb/Vote_Res_Map.asp?vote_id_t='+str(rule_id)

        current_path = os.getcwd()

        final_df = pd.concat(dataframes)
        
        final_df.to_csv(f'{current_path}/{rule_id}.csv', encoding='utf-8-sig', index=False)
        print("downloaded data for rule id: ", rule_id)
    except NoSuchElementException:
        print("can't find vote id: ", rule_id)