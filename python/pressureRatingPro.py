"""

    Script to calculate Pressure Rating Pro (TM)

    @author Wouter Diesveld

"""
import json
import math
import numpy as np
import statistics 
from dataPrep import *
from scipy.stats import pearsonr
from sklearn import decomposition

"""

   Settings

"""
dataSourceFile = '../data/pressure/atptour-pressure-career-all-all-false.json'
serveDataFile = '../data/serve/atptour-serve-career-all-all-false.json'
players = []
numberOfIterations = 1000
numberOfOutputDims = 4
features = [
    'brkPointsConvertedPct',
    'brkPointsSavedPct',
    'tieBreaksWonPct',
    'decidingSetsWonPct'
]

"""

   Functions

"""
def getNumber(string):
    if string[-1] == '%':
        return float(string[:-1])
    return float(string)

def printScoreList(players):
    print("\nscorelist")
    for i, player in enumerate(players[:20]):
        print(str(i+1) + ": " + player['playerName'] + " (" + "{:.2f}".format(player['pressureRatingPro']) + ")")

def readPlayerData(fileName):
    print("Reading " + fileName)
    with open(fileName) as json_file:
        players = json.load(json_file)['leaderboard']
    # Preprocessing
    for player in players:
        # Remove '%' signs
        for key in player['stats'].keys():
            player['stats'][key] = getNumber(player['stats'][key])
    return players

def calculateWeights(players, features):
    print("Calculating weights")
    W = {}

    for feature in features:
        W[feature] = []

    # create input vectors X
    X = []
    for player in players:
        X.append(list(map(
            lambda feature: player['stats'][feature], 
            features
        )))

    for k in range(numberOfIterations):
        if k % 10 == 0:
            print(".", end = '', flush=True)

        pca = decomposition.FastICA(n_components=numberOfOutputDims, whiten=True)
        Xtrans = pca.fit_transform(X)
        w = []
        # Pick the dimension which adds up all features XOR subtracts all features
        for comp in pca.components_:
            sumAbs = sum(map(abs,comp))
            absSum = abs(sum(comp))
            if (sumAbs == absSum):
                w = list(map(lambda x:abs(x/sumAbs),comp))
        if len(w) > 0:
            for i,feature in enumerate(features):
                W[feature].append(w[i])

    # Calculate mean weight vector
    for feature in features:
        W[feature] = statistics.mean(W[feature])

    print("Ready")
    return W, pca, Xtrans

def determineSourceCorrelatingWithServing(players):
    avgAcesPerMatch = list(map(
        lambda player: player['stats']['avgAcesPerMatch'],
        players
    ))
    corr = []
    for i in range(0,len(features)):
        r,_ = pearsonr(
            avgAcesPerMatch,
            list(map(
                lambda x:x[i],
                Xtrans
            ))
        )
        corr.append(r)
    sourceHighestCorr = np.argmax(list(map(abs,corr)))
    if corr[sourceHighestCorr] > 0:
        sign = 1
    else:
        sign = -1
    return sourceHighestCorr,sign

def setPressureRatingPro(players, W, features, pca, Xtrans):
    for player in players:
        player['pressureRatingPro'] = sum(map(
            lambda feature: player['stats'][feature] * W[feature], 
            features
        ))
        x = list(map(
            lambda feature: player['stats'][feature],
            features
        ))
        xTrans1 = pca.transform([x])
        player['sources'] = list(xTrans1[0])

def addServingStats(players, playersServing, dimHighestCorr = -1, sign = 0):
    for player in players:
        for playerServe in playersServing:
            if playerServe['playerId'] == player['playerId']:
                player['stats']['avgAcesPerMatch'] = playerServe['stats']['avgAcesPerMatch']
        if dimHighestCorr != -1:
            player['sourceCorrServe'] = player['sources'][dimHighestCorr] * sign


"""

   Start of script

"""

players = readPlayerData(dataSourceFile)

W, pca, Xtrans = calculateWeights(players, features)

print("Calulated weights:")
for key in W.keys():
    print(key + ": " + str(W[key]))

playersServing = readPlayerData(serveDataFile)
playersTitles = parseTitles('../data/titles/atptour-titles-career.html')

addServingStats(players, playersServing)
dimHighestCorr,sign = determineSourceCorrelatingWithServing(players)

print("Write output to json files..")

with open('../output/pressure/pressureRatingProWeights.json', 'w') as outfile:
    json.dump(W, outfile)

print("Calculating new pressure score for each player and year..")
for setName in ['career'] + list(range(1991,2021)):
    playersSet = readPlayerData('../data/pressure/atptour-pressure-'+str(setName)+'-all-all-false.json')
    for i,player in enumerate(playersSet):
        player['stats']['rankPressureRating'] = i+1
    setPressureRatingPro(playersSet, W, features, pca, Xtrans)
    addServingStats(playersSet, playersServing, dimHighestCorr,sign)
    playersSet.sort(key=lambda player:player['pressureRatingPro'], reverse=True)
    # printScoreList(playersSet)
    playersSet = mergePlayers(playersSet, playersTitles)
    for player in playersSet:
        if math.isnan(player['titles']):
            player['titles'] = 0
        if player['yearNo1'] is None or math.isnan(player['yearNo1']):
            player['yearNo1'] = 0
    with open('../output/pressure/rating-pro-'+str(setName)+'.json', 'w') as outfile:
        json.dump(playersSet, outfile)

print("Ready")
