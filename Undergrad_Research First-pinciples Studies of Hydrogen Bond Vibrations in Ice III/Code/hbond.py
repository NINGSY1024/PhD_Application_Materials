import os
import sys
import getopt
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import readxsd as rs
import readxtd as rt

def density(x, sigma):
    y = np.exp(- x ** 2 / (2 * sigma ** 2))
    return y

def freqcurve(x, modelist, sigma):
    num = len(x)
    y = np.zeros(num)
    for I in range(num):
        for J in range(len(modelist)):
            y[I] = y[I] + density(x[I] - modelist[J], sigma)
    return y

def plotstretch():
    x = ModeFreq
    plt.figure()
    plt.scatter(x, stretchSum)
    plt.ylim(bottom=-2)
    plt.xlabel(r'Wavenumber(cm$^{-1}$)')
    plt.ylabel('Length')
    plt.title(title)
    if output:
        filename = title
        dataframe = pd.DataFrame({'Wavenumber': x, 'Length': stretchSum})
        dataframe.to_csv(filename + '.csv', index=False, sep=',')
        plt.savefig(filename + '.png')
    plt.show()

def countpeak8(switch):
    lo = []
    to = []
    ft = []
    for I in range(M):
        argsort = ModeIntensity[I].argsort()[-dots:]
        for J in range(dots):
            if intLim[0] <= ModeIntensity[I][argsort[J]] <= intLim[1]:
                loAng = modeBisAng[I][argsort[J]]
                toAng = modeEdgeAng[I][argsort[J]]
                if switch:
                    toAng = modeTOAng[I][argsort[J]]
                limit = (loAng + toAng) * angRatio
                if 170 < ModeFreq[I] < 180:
                    ft.append(ModeFreq[I])
                else:
                    if loAng <= limit - criticAng:
                        lo.append(ModeFreq[I])
                    elif toAng <= limit - criticAng:
                        to.append(ModeFreq[I])
    plt.figure()
    num = 1000
    x = np.linspace(ModeFreq.min() - 3 * smooth, 400, num)
    y1 = freqcurve(x, lo, smooth)
    y2 = freqcurve(x, to, smooth)
    y3 = freqcurve(x, ft, smooth)
    plt.plot(x, y1, color='blue')
    plt.fill_between(x, 0, y1, color='blue', alpha=0.3)
    plt.plot(x, y2, color='red')
    plt.fill_between(x, 0, y2, color='red', alpha=0.3)
    plt.plot(x, y3, color='green')
    plt.fill_between(x, 0, y3, color='green', alpha=0.3)
    plt.xlim(freqLim[0] - 3 * 4, freqLim[1] + 3 * 4)
    plt.ylim(0, 6)
    plt.xlabel(r'Wavenumber(cm$^{-1}$)')
    plt.ylabel('Counts')
    plt.title(title)
    if output:
        filename = title + ' -m 2d' + ' -c ' + str(criticAng) + ' -I [' + str(round(intLim[0], 3)) + ',' + str(round(intLim[1], 3)) + '] -F [' + str(round(freqLim[0], 3)) + ',' + str(round(freqLim[1], 3)) + '] -s ' + str(smooth)
        dataframe = pd.DataFrame({'Wavenumber': x, 'TO': y1, 'LO': y2, 'FT': y3})
        dataframe.to_csv(filename + '.csv', index=False, sep=',')
        plt.savefig(filename + '.png')
    plt.show()

def usage():
    print("
    -h /--help          : help
    ")