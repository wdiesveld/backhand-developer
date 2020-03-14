import requests
import time
import urllib
from bs4 import BeautifulSoup
import pandas as pd

def mergePlayers(players1, players2):
    df1 = pd.DataFrame(players1).set_index('playerId')
    df2 = pd.DataFrame(players2).set_index('playerId')
    df = df1.merge(df2, left_index=True, right_index=True, how='left')
    dic = df.T.to_dict()
    result = []
    for key in dic:
        dic[key]['playerId'] = key
        result.append(dic[key])
    return result

def parseTitles(htmlFile):
    with open(htmlFile) as file:
        html = file.read()
    soup = BeautifulSoup(html, "html.parser")
    players = []

    for tr in soup.find('tbody', id='winLossTableContent').findAll('tr'):
        playerId = tr.find('td', class_='player-cell').find('a').get('href').split('/')[4].upper()
        titles = tr.find('td', class_='fifty-two-week-titles-cell').text.strip()
        if (titles == '-'):
            titles = 0
        else:
            titles = int(titles)
        players.append({
            'playerId': playerId,
            'titles': titles
        })

    return players

def fetchDataFromATP():
    print("Fetching data from atptour.com")
    for year in range(2019, 2020):
        print("Fetching year " + str(year))
        link = "https://www.atptour.com/-/ajax/StatsLeaderboard/en/pressure/" + str(year) + "/all/all/false"
        infile = urllib.request.urlopen(link)
        with open('../data/pressure/atp-pressure-'+ str(year) +'.json', 'w') as outfile:
           outfile.write(infile.read())