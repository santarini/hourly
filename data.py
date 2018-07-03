import csv
import itertools
from itertools import zip_longest
import re
import os
import datetime as dt
import pandas_datareader.data as web

batch = []

#create source folder if it doesnt exist yet
if not os.path.exists('StockDatabase'):
    os.makedirs('StockDatabase')

with open("tester.csv", encoding='utf-8') as csvfile:
    reader = csv.reader(csvfile)
    data = list(reader)
    rowCount = len(data)
    for element in data:
        for innerStr in element:
            batch.append(innerStr)
    print(batch)


        

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
