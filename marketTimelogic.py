import datetime

#NYSE,NASDAQ,AMEX (Hours 9:30am-4:00pm)

weekdays = ['monday','tuesday','wednesday','thursday','friday']

def job():
    n = datetime.datetime.now()
    print("Test " + str(n))

for i in range(17,18):
    for j in range(6,11,1):
        for k in range(1,4):
            if j == 0:
                timeHolder = (str(i) + ":" + str(j) + "0")
                dayHolder = weekdays[k]
                schedule.every().dayHolder.at(timeHolder).do(job)
            else:
                timeHolder = (str(i) + ":0" + str(j))
                dayHolder = weekdays[k]
                schedule.every().dayHolder.at(timeHolder).do(job)
            
while True:
    schedule.run_pending()
