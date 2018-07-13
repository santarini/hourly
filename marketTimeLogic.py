import datetime
import schedule

#NYSE,NASDAQ,AMEX (MWF 9:30am-4:00pm)

def job():
    n = datetime.datetime.now()
    print("Test " + str(n))

for i in range(9,17):
    for j in range(0,60,10):
        if j < 10:
            timeHolder = (str(i) + ":0" + str(j))
        else:
            timeHolder = (str(i) + ":" + str(j))
            schedule.every().monday.at(timeHolder).do(job)
            schedule.every().tuesday.at(timeHolder).do(job)
            schedule.every().wednesday.at(timeHolder).do(job)
            schedule.every().thursday.at(timeHolder).do(job)
            schedule.every().friday.at(timeHolder).do(job)
while True:
    schedule.run_pending()
