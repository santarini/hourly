import csv
import itertools
from itertools import zip_longest
import re
import os
import datetime as dt
import pandas_datareader.data as web
import requests
import json

batch = []

CurrentTicker = "AAPL"

def dataRequest(batchReq):
        response = requests.get('https://api.iextrading.com/1.0/stock/market/batch?symbols=' + str(batchReq)+ '&types=company,quote,stats')
        jsonLoad = json.loads(response.text)
        return jsonLoad
        #jsonParsetoCSV(jsonLoad, CurrentTicker)

def jsonParsetoCSV(jsonLoad, CurrentTicker):
    with open('StockDatabase/'+ str(CurrentTicker) + '.csv', 'a', encoding="utf-8") as csvfileA:
        fieldnames = ['Date','Time','Price', 'Volume', 'MktCap','SharesOut', 'SharesFloat']
        #writer = csv.DictWriter(csvfileA, fieldnames=fieldnames, lineterminator = '\n')
        writer.writeheader()
        latestTime = jsonLoad[CurrentTicker]['quote']['latestTime']
        latestPrice = jsonLoad[CurrentTicker]['quote']['latestPrice']
        latestVolume = jsonLoad[CurrentTicker]['quote']['latestVolume']
        marketcap = jsonLoad[CurrentTicker]['stats']['marketcap']
        sharesOutstanding = jsonLoad[CurrentTicker]['stats']['sharesOutstanding']
        sharesFloat = jsonLoad[CurrentTicker]['stats']['float']
        writer.writerow({'Date': 'blank','Time': 'blank','Price': str(latestPrice), 'Volume': str(latestVolume), 'MktCap': str(marketcap),'SharesOut': str(sharesOutstanding), 'SharesFloat': str(sharesFloat)})
    

#create source folder if it doesnt exist yet
if not os.path.exists('StockDatabase'):
    os.makedirs('StockDatabase')

with open("AmericanTickers101.csv", encoding='utf-8') as csvfile:
    reader = csv.reader(csvfile)
    allTickers = list(reader)
    tickerCount = len(allTickers)
    QtyHundreds = tickerCount/100
    i = 0
    if QtyHundreds > 1:
        j = 100
        while QtyHundreds > 1:
            for ticker in allTickers[i:j]:
                for innerStr in ticker:
                    batch.append(innerStr)
            batchReq = ",".join(batch)
            jsonLoad = dataRequest(batchReq)
            for ticker in allTickers[i:j]:
                for innerStr in ticker:
                    CurrentTicker = innerStr
                    jsonParsetoCSV(jsonLoad, CurrentTicker)
            i = i + 100
            j = j + 100
            QtyHundreds = QtyHundreds - 1
            batch = []
    if QtyHundreds <= 1:
        for ticker in allTickers[i:tickerCount]:
            for innerStr in ticker:
                batch.append(innerStr)
        batchReq = ",".join(batch)
        jsonLoad = dataRequest(batchReq)
        for ticker in allTickers[i:tickerCount]:
            for innerStr in ticker:
                CurrentTicker = innerStr
                jsonParsetoCSV(jsonLoad, CurrentTicker)
