#!/usr/bin/env python3
# coding=utf-8

# Copyright 2017 Arthur Brugiere <contact@arthurbrugiere.fr>
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

from pandas import DataFrame, read_csv
import matplotlib.pyplot as plt
import pandas as pd 

dataFolder = "../GAMA_Project/includes/DATA/"
inputFile = dataFolder + "21-5-2019-_23HN_V1_Data_preliminary.xls"
dfResult = {}

def saveToCSV() :
	pd.DataFrame([dfResult]).to_csv( "./output.csv")

def averagePersonPerResidence(df):
	dfResult['avg_house'] = df['SUBJID'].value_counts().mean()

if __name__ == '__main__':
	averagePersonPerResidence( pd.read_excel(inputFile, "MEMBER") )

	saveToCSV()

	print("XX END XX")