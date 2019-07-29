#!/usr/bin/env python3
# coding=utf-8

# Copyright 2019 Arthur Brugiere <contact@arthurbrugiere.fr>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import sys

from pandas import DataFrame, read_csv
import matplotlib.pyplot as plt
import pandas as pd 

dataFolder = "../GAMA_Project/includes/DATA/"
inputFile = dataFolder + "21-5-2019-_23HN_V1_Data_preliminary.xls"
dfResult = {}

def saveToCSV(printFlag) :
	if printFlag :
		print( dfResult )
	else :
		pd.DataFrame([dfResult]).to_csv( "./output.csv")

def averagePersonPerResidence(df, irrevelant):
	# Average person per house
	dfResult['MEMB_avg_house'] = df['SUBJID'].value_counts().mean()
	
	# Average person under 5yo per house
	dfResult['MEMB_avg_house_under5'] = df[df.BIRTHYR >= 2014]['SUBJID'].value_counts().mean()

def extractFrom_HHILLNESS_Page(df, irrevelant):
	# Pref HC
	#	=> non-revelant (10 results on 850 lines)
	
	# Time before HC
	#	=> non-revelant (~34 results on 850 lines)
	if (irrevelant) :
		dfResult['HHIL_avg_dayBeforeHC'] = df['COFIRSTADVAFTER'].value_counts().mean()
	
	# get seek advice/treatment 
	# 	+> from any source?
	dfTmp = df[df.COTREAT.notnull()] # Drop empty row

	dfResult['HHIL_ADVICE_total'] = totalRow = len(dfTmp)
	dfTmp = dfTmp[ dfTmp.COTREAT == 1.0 ]

	dfResult['HHIL_ADVICE_noAdvice'] = totalRow - len(dfTmp)

	count = 0
	for i in ["COGOVHOSPITAL", "COPMC", "COCOMMHEALTH", "COPRIVATEHOSP", "COPHARMACY", "COSHOP", "COTRAPRACTITIONER", "COFRIEND"]:

		temp = dfTmp[i].value_counts()		
		# Get total TRUE for each HC
		dfResult['HHIL_ADVICE_trueNbr_hcAdvice_'+str(count)] = (len(dfTmp) - temp[0])

		count = count+1

	# ! for

#["COGOVHOSPITAL", "COPMC", "COCOMMHEALTH", "COPRIVATEHOSP", "COPHARMACY", "COSHOP", "COTRAPRACTITIONER", "COFRIEND"]

if __name__ == '__main__':

	# HEADER SCRIPT :D
	print("""+=============================+
|   OUCRU-GAMA Data fetcher   |
|     by RoiArthurB           |
|     (c) 2019                |
+=============================+""")

	# local var
	irrevelant = False
	printDF = False

	# set script arguments
	try:
		if len(sys.argv) > 1 :
			for i in sys.argv:
				if i == "-i" :
					irrevelant = True
					pass

				if i == "-p" :
					printDF = True
					pass

				if i == "-h" :
					raise -1

			#	pass
			#sys.argv.index("-v")
			#print(sys.argv.index("-b"))
	except: 
		print("""You want to use arguments on this script but you don't know how... 
Here's a little help just for you ;)
	-h : display this message and exit
	-i : will process irrevelant values
	-p : will print DataFrame and not save it
	""")
		sys.exit()

	print("== STARTING SCRIPT ==")


	print("Loading script input file : " + inputFile)

	## MEMBER
	print("-- starting MEMBER sheet --")
	averagePersonPerResidence( pd.read_excel(inputFile, "MEMBER"), irrevelant )

	## HHINFO
	print("-- starting HHINFO sheet --")
	# Antibio + Animals
	# Water 
	# 	Soap
	# 	Cleaning
	# Toilets
	# Cooking / Fuel
	# Info / Social Network
	# Antibio name knowledge
	
	## HIST
	print("-- starting HIST sheet --")
	#	Question about 5yo children in the house
	# 
	# Cesarienne
	# Alaitement
	# Health book
	# 	Vaccine
	
	## HHILLNESS
	print("-- starting HHILLNESS sheet --")
	# 
	# (from) Seek advice / treatment
	# 	If > 1 => which first ?
	# How many days before HC
	# 
	# What treatment ?	Antibio / Homemade / other
	# Where get pills from 
	# 
	extractFrom_HHILLNESS_Page( pd.read_excel(inputFile, "HHILLNESS"), irrevelant )

	## ACCESSHC
	print("-- starting ACCESSHC sheet --")
	# 

	saveToCSV(printDF)

	print("XX END XX")