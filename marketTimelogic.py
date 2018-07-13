def job():
    k = datetime.datetime.now()
    print("Test " + str(k))

for i in range(16,17):
    for j in range(21,30,1):
        if j == 0:
            timeHolder = (str(i) + ":" + str(j) + "0")
            schedule.every().day.at(timeHolder).do(job)
        else:
            timeHolder = (str(i) + ":" + str(j))
            schedule.every().day.at(timeHolder).do(job)
            
while True:
    schedule.run_pending()
