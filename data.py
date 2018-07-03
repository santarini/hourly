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

#create source folder if it doesnt exist yet
if not os.path.exists('StockDatabase'):
    os.makedirs('StockDatabase')

with open("AmericanTickers100.csv", encoding='utf-8') as csvfile:
    reader = csv.reader(csvfile)
    allTickers = list(reader)
    tickerCount = len(allTickers)
    for ticker in allTickers:
        for innerStr in ticker:
            batch.append(innerStr)
    batchReq = ",".join(batch)
    #make request fetch data
    response = requests.get('https://api.iextrading.com/1.0/stock/market/batch?symbols=' + str(batchReq)+ '&types=company,quote,stats')
    jsonLoad = json.loads(response.text)
    companyName = JsonLoad[CurrentTicker]['company']['companyName']
    website = JsonLoad[CurrentTicker]['company']['website']
    description = JsonLoad[CurrentTicker]['company']['description']
    exchange = JsonLoad[CurrentTicker]['company']['exchange']
    sector = JsonLoad[CurrentTicker]['company']['sector']
    industry = JsonLoad[CurrentTicker]['company']['industry']
    CEO = JsonLoad[CurrentTicker]['company']['CEO']
    issueType = JsonLoad[CurrentTicker]['company']['issueType']
    latestTime = JsonLoad[CurrentTicker]['quote']['latestTime']
    latestPrice = JsonLoad[CurrentTicker]['quote']['latestPrice']
    latestVolume = JsonLoad[CurrentTicker]['quote']['latestVolume']
    marketcap = JsonLoad[CurrentTicker]['stats']['marketcap']
    sharesOutstanding = JsonLoad[CurrentTicker]['stats']['sharesOutstanding']
    sharesFloat = JsonLoad[CurrentTicker]['stats']['float']




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
