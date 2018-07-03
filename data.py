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
        writer = csv.DictWriter(csvfileA, fieldnames=fieldnames, lineterminator = '\n')
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







##    if not os.path.exists('stock_dfs/{}.csv'.format(ticker)):
##        start = dt.datetime(2017,1,1)
##        end = dt.datetime(2018,1,1)
##        #use 'morningstar' for stocks
##        df = web.DataReader(ticker, "iex", start, end)
##        #use 'stooq' for indexes no dates necessary
##        #df = web.DataReader('^DJI', 'stooq')
##        df.to_csv('stock_dfs/{}.csv'.format(ticker))
##        #you can also print these to test the program instead of going head first into csv
##        #print(df.head())
##    else:
##        print('Already have {}'.format(ticker))
##    print(",".join(batch))
##

##QtyHundreds = tickerCount/100
##        for item in allTickers[1:3]:
##        batchReq = ",".join(item)
##    print(batchReq)


        

            #rawRow = re.search('[(.*)]', row)
        #print(rawRow)


##with open("tester.csv", encoding='utf-8') as csvfile:
##    reader = csv.reader(csvfile)
##    rowCount = sum(1 for row in reader)
##    qtyHundreds = rowCount/100
##
####    if qtyHundreds > 1:
####        #do some opeartion
##
##    for row in itertools.islice(reader, 0, 50):
##        print(row)


##
##i = 2
##
###open csv
##with open("tester.csv", encoding='utf-8') as csvfile:
##    reader = csv.DictReader(csvfile)
##    rowCount = sum(1 for row in reader)
##    qtyHundreds = rowCount/100
##    for i, row in enumerate(reader):
##        if i == N:
##            print("This is the line.")
##            print(row)
##            break
##            
##    print(rowCount)
##    print(round(qtyHundreds))
##
###count number of cells in column
###i = number of cells in column/100
###j = 1
###
