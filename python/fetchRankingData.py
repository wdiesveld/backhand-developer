from urllib import request
import time
from datetime import date, timedelta
from pathlib import Path
import subprocess
import sys

def allMondays(year):
   d = date(year, 1, 1)
   d += timedelta(days = (7 - d.weekday())%7)  # First Monday
   while d.year == year:
      yield d
      d += timedelta(days = 7)

def fetchRankingDataForDate(ranking_date):
    year = ranking_date[:4]
    month = ranking_date[5:7]
    day = ranking_date[8:10]
    print(ranking_date)
    outfilename = '../data/rankings/rankings-'+ranking_date+'.json'
    if Path(outfilename).is_file():
        print("file exists, skip downloading")
    else:
        dateReversed = day + '-' + month + '-' + year
        link = "https://www.ultimatetennisstatistics.com/rankingsTableTable?current=1&rowCount=-1&sort%5Brank%5D=asc&searchPhrase=&rankType=RANK&season=" + year + "&date=" + dateReversed
        infile = request.urlopen(link)
        with open(outfilename, 'w') as outfile:
            outfile.write(infile.read().decode('utf-8'))
    subprocess.run(["dbt", "run-operation", "load_ranking_raw",  "--args", "{ranking_date: \""+ranking_date+"\"}", "--project-dir", "../dbt"])

def fetchRankingDataPerYear(year):
    print("Fetching data from ultimatetennisstatistics.com")
    print("Fetching year " + str(year))
    for d in allMondays(int(year)):
        fetchRankingDataForDate(str(d))


nArgs = len(sys.argv)
if nArgs == 1:
    print("usage:")
    print(sys.argv[0] + " --year 2021")
    print(sys.argv[0] + " --year 2020-2022")
    print(sys.argv[0] + " --date 2020-01-06")
elif sys.argv[1] == "--year":
    years = sys.argv[2].split('-')
    min = int(years[0])
    max = int(years[-1])
    for y in range(min, max):
        fetchRankingDataPerYear(y)
elif sys.argv[1] == "--date":
    fetchRankingDataForDate(sys.argv[2])
else:
    print("illegal call")




